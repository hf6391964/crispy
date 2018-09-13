# coding: utf-8
# /*##########################################################################
#
# Copyright (c) 2016-2018 European Synchrotron Radiation Facility
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# ###########################################################################*/

from __future__ import absolute_import, division, unicode_literals

__authors__ = ['Marius Retegan']
__license__ = 'MIT'
__date__ = '13/09/2018'


import copy
import datetime
import gzip
import json
import numpy as np
import os
try:
    import cPickle as pickle
except ImportError:
    import pickle
import re
import subprocess
import sys

from PyQt5.QtCore import (
    QItemSelectionModel, QItemSelection, QProcess, Qt, QPoint, QStandardPaths)
from PyQt5.QtGui import QIcon
from PyQt5.QtWidgets import (
    QDockWidget, QFileDialog, QAction, QMenu, QWidget,
    QDialog, QDialogButtonBox)
from PyQt5.uic import loadUi
from silx.resources import resource_filename as resourceFileName

from .models import HamiltonianModel, ResultsModel, PolarizationsModel
from ..utils.broaden import broaden
from ..utils.odict import odict
from ..version import version


class QuantyCalculation(object):

    _defaults = odict(
        [
            ('version', version),
            ('element', 'Ni'),
            ('charge', '2+'),
            ('symmetry', 'Oh'),
            ('experiment', 'XAS'),
            ('edge', 'L2,3 (2p)'),
            ('temperature', 10.0),
            ('magneticField', 0.0),
            ('e1Min', None),
            ('e1Max', None),
            ('e1NPoints', None),
            ('e1Lorentzian', None),
            ('e1Gaussian', None),
            ('k1', [0, 0, 1]),
            ('eps11', [0, 1, 0]),
            ('eps12', [1, 0, 0]),
            ('e2Min', None),
            ('e2Max', None),
            ('e2NPoints', None),
            ('e2Lorentzian', None),
            ('e2Gaussian', None),
            ('k2', [0, 0, 0]),
            ('eps21', [0, 0, 0]),
            ('eps22', [0, 0, 0]),
            ('polarizations', None),
            ('nPsisAuto', 1),
            ('nConfigurations', 1),
            ('fk', 0.8),
            ('gk', 0.8),
            ('zeta', 1.0),
            ('hamiltonianData', None),
            ('hamiltonianState', None),
            ('baseName', 'untitled'),
            ('spectrum', None),
            ('startingTime', None),
            ('endingTime', None),
            ('verbosity', None),
        ]
    )

    # Make the parameters a class attribute. This speeds up the creation
    # of a new calculation object; significantly.
    path = resourceFileName(
        'crispy:' + os.path.join('modules', 'quanty', 'parameters',
                                 'parameters.json.gz'))

    with gzip.open(path, 'rb') as p:
        parameters = json.loads(
            p.read().decode('utf-8'), object_pairs_hook=odict)

    def __init__(self, **kwargs):
        self.__dict__.update(self._defaults)
        self.__dict__.update(kwargs)

        parameters = self.parameters

        branch = parameters['elements']
        self.elements = list(branch)
        if self.element not in self.elements:
            self.element = self.elements[0]

        branch = branch[self.element]['charges']
        self.charges = list(branch)
        if self.charge not in self.charges:
            self.charge = self.charges[0]

        branch = branch[self.charge]['symmetries']
        self.symmetries = list(branch)
        if self.symmetry not in self.symmetries:
            self.symmetry = self.symmetries[0]

        branch = branch[self.symmetry]['experiments']
        self.experiments = list(branch)
        if self.experiment not in self.experiments:
            self.experiment = self.experiments[0]

        branch = branch[self.experiment]['edges']
        self.edges = list(branch)
        if self.edge not in self.edges:
            self.edge = self.edges[0]

        branch = branch[self.edge]

        self.templateName = branch['template name']

        self.configurations = branch['configurations']
        self.block = self.configurations[0][1][:2]
        self.nElectrons = int(self.configurations[0][1][2:])
        self.nPsis = branch['number of states']
        self.nPsisMax = self.nPsis
        self.hamiltonianTerms = branch['hamiltonian terms']

        self.e1Label = branch['axes'][0][0]
        self.e1Min = branch['axes'][0][1]
        self.e1Max = branch['axes'][0][2]
        self.e1NPoints = branch['axes'][0][3]
        self.e1Edge = branch['axes'][0][4]
        self.e1Lorentzian = branch['axes'][0][5]
        self.e1Gaussian = branch['axes'][0][6]

        if self.experiment == 'RIXS':
            self.e2Label = branch['axes'][1][0]
            self.e2Min = branch['axes'][1][1]
            self.e2Max = branch['axes'][1][2]
            self.e2NPoints = branch['axes'][1][3]
            self.e2Edge = branch['axes'][1][4]
            self.e2Lorentzian = branch['axes'][1][5]
            self.e2Gaussian = branch['axes'][1][6]

        if self.polarizations is None:
            self.polarizations = dict()
            if self.experiment == 'XAS':
                self.polarizations['all'] = [
                    'Isotropic', 'Circular Dichroism', 'Linear Dichroism',
                    'Parallel']
            else:
                self.polarizations['all'] = ['Isotropic']
            self.polarizations['checked'] = ['Isotropic']

        if self.hamiltonianData is None:
            self.hamiltonianData = odict()

        if self.hamiltonianState is None:
            self.hamiltonianState = odict()

        self.fixedTermsParameters = odict()

        branch = parameters['elements'][self.element]['charges'][self.charge]

        for label, configuration in self.configurations:
            label = '{} Hamiltonian'.format(label)
            terms = branch['configurations'][configuration]['terms']

            for term in self.hamiltonianTerms:
                if term in ('Atomic', 'Magnetic Field', 'Exchange Field'):
                    node = terms[term]
                else:
                    node = terms[term]['symmetries'][self.symmetry]

                parameters = node['parameters']['variable']
                for parameter in parameters:
                    if term in 'Atomic':
                        if parameter[0] in ('F', 'G'):
                            scaling = 0.8
                        else:
                            scaling = 1.0
                        data = [parameters[parameter], scaling]
                    else:
                        data = parameters[parameter]

                    self.hamiltonianData[term][label][parameter] = data

                parameters = terms[term]['parameters']['fixed']
                for parameter in parameters:
                    value = parameters[parameter]
                    self.fixedTermsParameters[term][parameter] = value

                if term in ('Atomic', 'Crystal Field'):
                    self.hamiltonianState[term] = 2
                else:
                    self.hamiltonianState[term] = 0

    def saveInput(self):
        templatePath = resourceFileName(
            'crispy:' + os.path.join('modules', 'quanty', 'templates',
                                     '{}'.format(self.templateName)))

        with open(templatePath) as p:
            self.template = p.read()

        replacements = odict()

        # TODO: Make this an object attribute when saving the .pkl file
        # doesn't brake compatibility.
        replacements['$DenseBorder'] = self.denseBorder
        replacements['$Verbosity'] = self.verbosity
        replacements['$NConfigurations'] = self.nConfigurations

        subshell = self.configurations[0][1][:2]
        subshell_occupation = self.configurations[0][1][2:]
        replacements['$NElectrons_{}'.format(subshell)] = subshell_occupation

        replacements['$T'] = self.temperature

        replacements['$Emin1'] = self.e1Min
        replacements['$Emax1'] = self.e1Max
        replacements['$NE1'] = self.e1NPoints
        replacements['$Eedge1'] = self.e1Edge

        if len(self.e1Lorentzian) == 1:
            replacements['$Gamma1'] = 0.1
            replacements['$Gmin1'] = self.e1Lorentzian[0]
            replacements['$Gmax1'] = self.e1Lorentzian[0]
            replacements['$Egamma1'] = (self.e1Min + self.e1Max) / 2
        else:
            replacements['$Gamma1'] = 0.1
            replacements['$Gmin1'] = self.e1Lorentzian[0]
            replacements['$Gmax1'] = self.e1Lorentzian[1]
            if len(self.e1Lorentzian) == 2:
                replacements['$Egamma1'] = (self.e1Min + self.e1Max) / 2
            else:
                replacements['$Egamma1'] = self.e1Lorentzian[2]

        s = '{{{0:.8g}, {1:.8g}, {2:.8g}}}'

        u = np.array(self.k1)
        u = u / np.linalg.norm(u)
        replacements['$k1'] = s.format(u[0], u[1], u[2])

        v = np.array(self.eps11)
        v = v / np.linalg.norm(v)
        replacements['$eps11'] = s.format(v[0], v[1], v[2])

        w = np.array(self.eps12)
        w = w / np.linalg.norm(w)
        replacements['$eps12'] = s.format(w[0], w[1], w[2])

        replacements['$polarizations'] = ', '.join(
            '\'{}\''.format(p) for p in self.polarizations['checked'])

        if self.experiment == 'RIXS':
            # The Lorentzian broadening along the incident axis cannot be
            # changed in the interface, and must therefore be set to the
            # final value before the start of the calculation.
            # replacements['$Gamma1'] = self.e1Lorentzian
            replacements['$Emin2'] = self.e2Min
            replacements['$Emax2'] = self.e2Max
            replacements['$NE2'] = self.e2NPoints
            replacements['$Eedge2'] = self.e2Edge
            replacements['$Gamma2'] = self.e2Lorentzian[0]

        replacements['$NPsisAuto'] = self.nPsisAuto
        replacements['$NPsis'] = self.nPsis

        aliases = odict(
            [
                ('Atomic', 'H_atomic'),
                ('Crystal Field', 'H_cf'),
                ('3d-Ligands Hybridization', 'H_3d_Ld_hybridization'),
                ('4d-Ligands Hybridization', 'H_4d_Ld_hybridization'),
                ('5d-Ligands Hybridization', 'H_5d_Ld_hybridization'),
                ('3d-4p Hybridization', 'H_3d_4p_hybridization'),
                ('Magnetic Field', 'H_magnetic_field'),
                ('Exchange Field', 'H_exchange_field'),
            ]
        )

        for term in self.hamiltonianData:
            configurations = self.hamiltonianData[term]
            for configuration, parameters in configurations.items():
                if 'Initial' in configuration:
                    suffix = 'i'
                elif 'Intermediate' in configuration:
                    suffix = 'm'
                elif 'Final' in configuration:
                    suffix = 'f'
                for parameter, data in parameters.items():
                    # Convert to parameters name from Greek letters.
                    parameter = parameter.replace('ζ', 'zeta')
                    parameter = parameter.replace('Δ', 'Delta')
                    parameter = parameter.replace('σ', 'sigma')
                    parameter = parameter.replace('τ', 'tau')
                    parameter = parameter.replace('μ', 'mu')
                    parameter = parameter.replace('ν', 'nu')
                    scaling = None
                    try:
                        value, scaling = data
                    except TypeError:
                        value = data
                    key = '${}_{}_value'.format(parameter, suffix)
                    replacements[key] = '{}'.format(value)
                    if scaling is not None:
                        key = '${}_{}_scaling'.format(parameter, suffix)
                        replacements[key] = '{}'.format(scaling)

            checkState = self.hamiltonianState[term]
            if checkState > 0:
                checkState = 1

            alias = aliases[term]
            replacements['${}'.format(alias)] = checkState

            try:
                parameters = self.fixedTermsParameters[term]
            except KeyError:
                pass
            else:
                for parameter in parameters:
                    value = parameters[parameter]
                    replacements['${}'.format(parameter)] = value

        replacements['$Experiment'] = self.experiment
        replacements['$BaseName'] = self.baseName

        for replacement in replacements:
            self.template = self.template.replace(
                replacement, str(replacements[replacement]))

        with open(self.baseName + '.lua', 'w') as f:
            f.write(self.template)


class QuantyDockWidget(QDockWidget):

    def __init__(self, parent=None, settings=None):
        super(QuantyDockWidget, self).__init__(parent=parent)
        self.settings = settings

        # Load the external .ui file for the widget.
        path = resourceFileName(
            'crispy:' + os.path.join('gui', 'uis', 'quanty', 'main.ui'))
        loadUi(path, baseinstance=self, package='crispy.gui')

        self.calculation = QuantyCalculation()
        self.populateWidget()
        self.enableActions()

        self.timeout = 4000

        self.hamiltonianSplitter.setSizes((150, 300, 10))

    def enableActions(self):
        self.elementComboBox.currentTextChanged.connect(self.resetCalculation)
        self.chargeComboBox.currentTextChanged.connect(self.resetCalculation)
        self.symmetryComboBox.currentTextChanged.connect(self.resetCalculation)
        self.experimentComboBox.currentTextChanged.connect(
            self.resetCalculation)
        self.edgeComboBox.currentTextChanged.connect(self.resetCalculation)

        self.temperatureLineEdit.editingFinished.connect(
            self.updateTemperature)
        self.magneticFieldLineEdit.editingFinished.connect(
            self.updateMagneticField)

        self.e1MinLineEdit.editingFinished.connect(self.updateE1Min)
        self.e1MaxLineEdit.editingFinished.connect(self.updateE1Max)
        self.e1NPointsLineEdit.editingFinished.connect(self.updateE1NPoints)
        self.e1LorentzianLineEdit.editingFinished.connect(
            self.updateE1Lorentzian)
        self.e1GaussianLineEdit.editingFinished.connect(self.updateE1Gaussian)
        self.k1LineEdit.editingFinished.connect(self.updateIncidentWaveVector)
        self.eps11LineEdit.editingFinished.connect(
            self.updateIncidentPolarizationVectors)

        self.e2MinLineEdit.editingFinished.connect(self.updateE2Min)
        self.e2MaxLineEdit.editingFinished.connect(self.updateE2Max)
        self.e2NPointsLineEdit.editingFinished.connect(self.updateE2NPoints)
        self.e2LorentzianLineEdit.editingFinished.connect(
            self.updateE2Lorentzian)
        self.e2GaussianLineEdit.editingFinished.connect(self.updateE2Gaussian)

        self.fkLineEdit.editingFinished.connect(self.updateScalingFactors)
        self.gkLineEdit.editingFinished.connect(self.updateScalingFactors)
        self.zetaLineEdit.editingFinished.connect(self.updateScalingFactors)

        self.syncParametersCheckBox.toggled.connect(self.updateSyncParameters)

        self.nPsisAutoCheckBox.toggled.connect(self.updateNPsisAuto)
        self.nPsisLineEdit.editingFinished.connect(self.updateNPsis)
        self.nConfigurationsLineEdit.editingFinished.connect(
            self.updateConfigurations)

        self.saveInputAsPushButton.clicked.connect(self.saveInputAs)
        self.calculationPushButton.clicked.connect(self.runCalculation)

    def populateWidget(self):
        """
        Populate the widget using data stored in the calculation
        object. The order in which the individual widgets are populated
        follows the way they are arranged.

        The models are recreated every time the function is called.
        This might seem to be an overkill, but in practice it is very fast.
        Don't try to move the model creation outside this function; is not
        worth the effort, and there is nothing to gain from it.
        """
        c = self.calculation

        self.elementComboBox.setItems(c.elements, c.element)
        self.chargeComboBox.setItems(c.charges, c.charge)
        self.symmetryComboBox.setItems(c.symmetries, c.symmetry)
        self.experimentComboBox.setItems(c.experiments, c.experiment)
        self.edgeComboBox.setItems(c.edges, c.edge)

        self.temperatureLineEdit.setValue(c.temperature)
        self.magneticFieldLineEdit.setValue(c.magneticField)

        self.energiesTabWidget.setTabText(0, str(c.e1Label))
        self.e1MinLineEdit.setValue(c.e1Min)
        self.e1MaxLineEdit.setValue(c.e1Max)
        self.e1NPointsLineEdit.setValue(c.e1NPoints)
        self.e1LorentzianLineEdit.setList(c.e1Lorentzian)
        self.e1GaussianLineEdit.setValue(c.e1Gaussian)

        self.k1LineEdit.setVector(c.k1)
        self.eps11LineEdit.setVector(c.eps11)
        self.eps12LineEdit.setVector(c.eps12)

        if c.experiment == 'RIXS':
            if self.energiesTabWidget.count() == 1:
                tab = self.energiesTabWidget.findChild(QWidget, 'e2Tab')
                self.energiesTabWidget.addTab(tab, tab.objectName())
                self.energiesTabWidget.setTabText(1, c.e2Label)
            self.e2MinLineEdit.setValue(c.e2Min)
            self.e2MaxLineEdit.setValue(c.e2Max)
            self.e2NPointsLineEdit.setValue(c.e2NPoints)
            self.e2LorentzianLineEdit.setList(c.e2Lorentzian)
            self.e2GaussianLineEdit.setValue(c.e2Gaussian)
            self.k2LineEdit.setVector(c.k2)
            self.eps21LineEdit.setVector(c.eps21)
            self.eps22LineEdit.setVector(c.eps22)
            text = self.eps11Label.text()
            text = re.sub('>[vσ]', '>σ', text)
            self.eps11Label.setText(text)
            text = self.eps12Label.text()
            text = re.sub('>[hπ]', '>π', text)
            self.eps12Label.setText(text)
        else:
            self.energiesTabWidget.removeTab(1)
            text = self.eps11Label.text()
            text = re.sub('>[vσ]', '>v', text)
            self.eps11Label.setText(text)
            text = self.eps12Label.text()
            text = re.sub('>[hπ]', '>h', text)
            self.eps12Label.setText(text)

        # Create the polarization model.
        self.polarizationsModel = PolarizationsModel(parent=self)
        self.polarizationsModel.setModelData(c.polarizations['all'])
        self.polarizationsModel.setCheckState(c.polarizations['checked'])
        self.polarizationsModel.checkStateChanged.connect(
            self.updatePolarizationsCheckState)
        self.polarizationsListView.setModel(self.polarizationsModel)

        self.fkLineEdit.setValue(c.fk)
        self.gkLineEdit.setValue(c.gk)
        self.zetaLineEdit.setValue(c.zeta)

        # Create the Hamiltonian model.
        self.hamiltonianModel = HamiltonianModel(parent=self)
        self.hamiltonianModel.setModelData(c.hamiltonianData)
        self.hamiltonianModel.setNodesCheckState(c.hamiltonianState)
        if self.syncParametersCheckBox.isChecked():
            self.hamiltonianModel.setSyncState(True)
        else:
            self.hamiltonianModel.setSyncState(False)
        self.hamiltonianModel.dataChanged.connect(self.updateHamiltonianData)
        self.hamiltonianModel.nodeCheckStateChanged.connect(
            self.updateHamiltonianNodeCheckState)

        # Assign the Hamiltonian model to the Hamiltonian terms view.
        self.hamiltonianTermsView.setModel(self.hamiltonianModel)
        self.hamiltonianTermsView.selectionModel().setCurrentIndex(
            self.hamiltonianModel.index(0, 0), QItemSelectionModel.Select)
        self.hamiltonianTermsView.selectionModel().selectionChanged.connect(
            self.selectedHamiltonianTermChanged)

        # Assign the Hamiltonian model to the Hamiltonian parameters view.
        self.hamiltonianParametersView.setModel(self.hamiltonianModel)
        self.hamiltonianParametersView.expandAll()
        self.hamiltonianParametersView.resizeAllColumnsToContents()
        self.hamiltonianParametersView.setColumnWidth(0, 130)
        self.hamiltonianParametersView.setRootIndex(
            self.hamiltonianTermsView.currentIndex())

        self.nPsisLineEdit.setValue(c.nPsis)
        self.nPsisAutoCheckBox.setChecked(c.nPsisAuto)
        self.nConfigurationsLineEdit.setValue(c.nConfigurations)

        self.nConfigurationsLineEdit.setEnabled(False)
        termName = '{}-Ligands Hybridization'.format(c.block)
        if termName in c.hamiltonianData:
            termState = c.hamiltonianState[termName]
            if termState != 0:
                self.nConfigurationsLineEdit.setEnabled(True)

        if not hasattr(self, 'resultsModel'):
            # Create the results model.
            self.resultsModel = ResultsModel(parent=self)
            self.resultsModel.calculationNameChanged.connect(
                self.updateCalculationName)
            self.resultsModel.dataChanged.connect(
                self.updateResultsViewSelection)

            # Assign the results model to the results view.
            self.resultsView.setModel(self.resultsModel)
            self.resultsView.selectionModel().selectionChanged.connect(
                self.selectedCalculationsChanged)
            self.resultsView.resizeColumnsToContents()
            self.resultsView.horizontalHeader().setSectionsMovable(False)
            self.resultsView.horizontalHeader().setSectionsClickable(False)
            if sys.platform == 'darwin':
                self.resultsView.horizontalHeader().setMaximumHeight(17)

            # Add a context menu to the view.
            self.resultsView.setContextMenuPolicy(Qt.CustomContextMenu)
            self.resultsView.customContextMenuRequested[QPoint].connect(
                self.showResultsContextMenu)

    def enableWidget(self, flag=True):
        self.elementComboBox.setEnabled(flag)
        self.chargeComboBox.setEnabled(flag)
        self.symmetryComboBox.setEnabled(flag)
        self.experimentComboBox.setEnabled(flag)
        self.edgeComboBox.setEnabled(flag)

        self.temperatureLineEdit.setEnabled(flag)
        self.magneticFieldLineEdit.setEnabled(flag)

        self.e1MinLineEdit.setEnabled(flag)
        self.e1MaxLineEdit.setEnabled(flag)
        self.e1NPointsLineEdit.setEnabled(flag)
        self.e1LorentzianLineEdit.setEnabled(flag)
        self.e1GaussianLineEdit.setEnabled(flag)
        self.k1LineEdit.setEnabled(flag)
        self.eps11LineEdit.setEnabled(flag)

        self.e2MinLineEdit.setEnabled(flag)
        self.e2MaxLineEdit.setEnabled(flag)
        self.e2NPointsLineEdit.setEnabled(flag)
        self.e2LorentzianLineEdit.setEnabled(flag)
        self.e2GaussianLineEdit.setEnabled(flag)

        self.fkLineEdit.setEnabled(flag)
        self.gkLineEdit.setEnabled(flag)
        self.zetaLineEdit.setEnabled(flag)

        self.syncParametersCheckBox.setEnabled(flag)

        self.nPsisAutoCheckBox.setEnabled(flag)
        if self.nPsisAutoCheckBox.isChecked():
            self.nPsisLineEdit.setEnabled(False)
        else:
            self.nPsisLineEdit.setEnabled(flag)

        self.nConfigurationsLineEdit.setEnabled(flag)

        self.hamiltonianTermsView.setEnabled(flag)
        self.hamiltonianParametersView.setEnabled(flag)
        self.resultsView.setEnabled(flag)

        self.saveInputAsPushButton.setEnabled(flag)

    def updateTemperature(self):
        temperature = self.temperatureLineEdit.getValue()

        if temperature < 0:
            message = 'The temperature cannot be negative.'
            self.getStatusBar().showMessage(message, self.timeout)
            self.temperatureLineEdit.setValue(self.calculation.temperature)
            return
        elif temperature == 0:
            self.nPsisAutoCheckBox.setChecked(False)
            self.updateNPsisAuto()
            self.nPsisLineEdit.setValue(1)
            self.updateNPsis()

        self.calculation.temperature = temperature

    def updateMagneticField(self):
        magneticField = self.magneticFieldLineEdit.getValue()

        if magneticField == 0:
            self.calculation.hamiltonianState['Magnetic Field'] = 0
        else:
            self.calculation.hamiltonianState['Magnetic Field'] = 2
        self.hamiltonianModel.setNodesCheckState(
            self.calculation.hamiltonianState)

        TESLA_TO_EV = 5.788e-05

        # Normalize the current incident vector.
        k1 = np.array(self.calculation.k1)
        k1 = k1 / np.linalg.norm(k1)

        configurations = self.calculation.hamiltonianData['Magnetic Field']
        for configuration in configurations:
            parameters = configurations[configuration]
            for i, parameter in enumerate(parameters):
                value = float(magneticField * np.abs(k1[i]) * TESLA_TO_EV)
                if abs(value) == 0.0:
                    value = 0.0
                configurations[configuration][parameter] = value
        self.hamiltonianModel.updateModelData(self.calculation.hamiltonianData)

        self.calculation.magneticField = magneticField

    def updateE1Min(self):
        e1Min = self.e1MinLineEdit.getValue()

        if e1Min > self.calculation.e1Max:
            message = ('The lower energy limit cannot be larger than '
                       'the upper limit.')
            self.getStatusBar().showMessage(message, self.timeout)
            self.e1MinLineEdit.setValue(self.calculation.e1Min)
            return

        self.calculation.e1Min = e1Min

    def updateE1Max(self):
        e1Max = self.e1MaxLineEdit.getValue()

        if e1Max < self.calculation.e1Min:
            message = ('The upper energy limit cannot be smaller than '
                       'the lower limit.')
            self.getStatusBar().showMessage(message, self.timeout)
            self.e1MaxLineEdit.setValue(self.calculation.e1Max)
            return

        self.calculation.e1Max = e1Max

    def updateE1NPoints(self):
        e1NPoints = self.e1NPointsLineEdit.getValue()

        e1Min = self.calculation.e1Min
        e1Max = self.calculation.e1Max
        e1LorentzianMin = float(self.calculation.e1Lorentzian[0])

        e1NPointsMin = int(np.floor((e1Max - e1Min) / e1LorentzianMin))
        if e1NPoints < e1NPointsMin:
            message = ('The number of points must be greater than '
                       '{}.'.format(e1NPointsMin))
            self.getStatusBar().showMessage(message, self.timeout)
            self.e1NPointsLineEdit.setValue(self.calculation.e1NPoints)
            return

        self.calculation.e1NPoints = e1NPoints

    def updateE1Lorentzian(self):
        try:
            e1Lorentzian = self.e1LorentzianLineEdit.getList()
        except ValueError:
            message = 'Invalid data for the Lorentzian brodening.'
            self.getStatusBar().showMessage(message, self.timeout)
            self.e1LorentzianLineEdit.setList(self.calculation.e1Lorentzian)
            return

        # Do some validation of the input value.
        if len(e1Lorentzian) > 3:
            message = 'The broadening can have at most three elements.'
            self.getStatusBar().showMessage(message, self.timeout)
            self.e1LorentzianLineEdit.setList(self.calculation.e1Lorentzian)
            return

        try:
            e1LorentzianMin = float(e1Lorentzian[0])
        except IndexError:
            pass
        else:
            if e1LorentzianMin < 0.1:
                message = 'The broadening cannot be smaller than 0.1.'
                self.getStatusBar().showMessage(message, self.timeout)
                self.e1LorentzianLineEdit.setList(
                    self.calculation.e1Lorentzian)
                return

        try:
            e1LorentzianMax = float(e1Lorentzian[1])
        except IndexError:
            pass
        else:
            if e1LorentzianMax < 0.1:
                message = 'The broadening cannot be smaller than 0.1.'
                self.getStatusBar().showMessage(message, self.timeout)
                self.e1LorentzianLineEdit.setList(
                    self.calculation.e1Lorentzian)

        try:
            e1LorentzianPivotEnergy = float(e1Lorentzian[2])
        except IndexError:
            pass
        else:
            e1Min = self.calculation.e1Min
            e1Max = self.calculation.e1Max

            if not (e1Min < e1LorentzianPivotEnergy < e1Max):
                message = ('The transition point must lie between the upper '
                           'and lower energy limits.')
                self.getStatusBar().showMessage(message, self.timeout)
                self.e1LorentzianLineEdit.setList(
                    self.calculation.e1Lorentzian)
                return

        self.calculation.e1Lorentzian = e1Lorentzian

    def updateE1Gaussian(self):
        e1Gaussian = self.e1GaussianLineEdit.getValue()

        if e1Gaussian < 0:
            message = 'The broadening cannot be negative.'
            self.getStatusBar().showMessage(message, self.timeout)
            self.e1GaussianLineEdit.setValue(self.calculation.e1Gaussian)
            return

        self.calculation.e1Gaussian = e1Gaussian

        try:
            index = list(self.resultsView.selectedIndexes())[-1]
        except IndexError:
            return
        else:
            self.resultsModel.replaceItem(index, self.calculation)
            self.plotSelectedCalculations()

    def updateIncidentWaveVector(self):
        try:
            k1 = self.k1LineEdit.getVector()
        except ValueError:
            message = 'Invalid data for the wave vector.'
            self.getStatusBar().showMessage(message, self.timeout)
            self.k1LineEdit.setVector(self.calculation.k1)
            return

        if np.all(np.array(k1) == 0):
            message = 'The wave vector cannot be null.'
            self.getStatusBar().showMessage(message, self.timeout)
            self.k1LineEdit.setVector(self.calculation.k1)
            return

        # The k1 value should be fine; save it.
        self.calculation.k1 = k1

        # The polarization vector must be correct.
        eps11 = self.eps11LineEdit.getVector()

        # If the wave and polarization vectors are not perpendicular, select a
        # new perpendicular vector for the polarization.
        if np.dot(np.array(k1), np.array(eps11)) != 0:
            if k1[2] != 0 or (-k1[0] - k1[1]) != 0:
                eps11 = (k1[2], k1[2], -k1[0] - k1[1])
            else:
                eps11 = (-k1[2] - k1[1], k1[0], k1[0])

        self.eps11LineEdit.setVector(eps11)
        self.calculation.eps11 = eps11

        # Generate a second, perpendicular, polarization vector to the plane
        # defined by the wave vector and the first polarization vector.
        eps12 = np.cross(np.array(eps11), np.array(k1))
        eps12 = eps12.tolist()

        self.eps12LineEdit.setVector(eps12)
        self.calculation.eps12 = eps12

        self.updateMagneticField()

    def updateIncidentPolarizationVectors(self):
        try:
            eps11 = self.eps11LineEdit.getVector()
        except ValueError:
            message = 'Invalid data for the polarization vector.'
            self.getStatusBar().showMessage(message, self.timeout)
            self.eps11LineEdit.setVector(self.calculation.eps11)
            return

        if np.all(np.array(eps11) == 0):
            message = 'The polarization vector cannot be null.'
            self.getStatusBar().showMessage(message, self.timeout)
            self.eps11LineEdit.setVector(self.calculation.eps11)
            return

        k1 = self.calculation.k1
        if np.dot(np.array(k1), np.array(eps11)) != 0:
            message = ('The wave and polarization vectors need to be '
                       'perpendicular.')
            self.getStatusBar().showMessage(message, self.timeout)
            self.eps11LineEdit.setVector(self.calculation.eps11)
            return

        self.calculation.eps11 = eps11

        # Generate a second, perpendicular, polarization vector to the plane
        # defined by the wave vector and the first polarization vector.
        eps12 = np.cross(np.array(eps11), np.array(k1))
        eps12 = eps12.tolist()

        self.eps12LineEdit.setVector(eps12)
        self.calculation.eps12 = eps12

    def updateE2Min(self):
        e2Min = self.e2MinLineEdit.getValue()

        if e2Min > self.calculation.e2Max:
            message = ('The lower energy limit cannot be larger than '
                       'the upper limit.')
            self.getStatusBar().showMessage(message, self.timeout)
            self.e2MinLineEdit.setValue(self.calculation.e2Min)
            return

        self.calculation.e2Min = e2Min

    def updateE2Max(self):
        e2Max = self.e2MaxLineEdit.getValue()

        if e2Max < self.calculation.e2Min:
            message = ('The upper energy limit cannot be smaller than '
                       'the lower limit.')
            self.getStatusBar().showMessage(message, self.timeout)
            self.e2MaxLineEdit.setValue(self.calculation.e2Max)
            return

        self.calculation.e2Max = e2Max

    def updateE2NPoints(self):
        e2NPoints = self.e2NPointsLineEdit.getValue()

        e2Min = self.calculation.e2Min
        e2Max = self.calculation.e2Max
        e2LorentzianMin = float(self.calculation.e2Lorentzian[0])

        e2NPointsMin = int(np.floor((e2Max - e2Min) / e2LorentzianMin))
        if e2NPoints < e2NPointsMin:
            message = ('The number of points must be greater than '
                       '{}.'.format(e2NPointsMin))
            self.getStatusBar().showMessage(message, self.timeout)
            self.e2NPointsLineEdit.setValue(self.calculation.e2NPoints)
            return

        self.calculation.e2NPoints = e2NPoints

    def updateE2Lorentzian(self):
        try:
            e2Lorentzian = self.e2LorentzianLineEdit.getList()
        except ValueError:
            message = 'Invalid data for the Lorentzian brodening.'
            self.getStatusBar().showMessage(message, self.timeout)
            self.e2LorentzianLineEdit.setList(self.calculation.e2Lorentzian)
            return

        # Do some validation of the input value.
        if len(e2Lorentzian) > 3:
            message = 'The broadening can have at most three elements.'
            self.getStatusBar().showMessage(message, self.timeout)
            self.e2LorentzianLineEdit.setList(self.calculation.e2Lorentzian)
            return

        try:
            e2LorentzianMin = float(e2Lorentzian[0])
        except IndexError:
            pass
        else:
            if e2LorentzianMin < 0.1:
                message = 'The broadening cannot be smaller than 0.1.'
                self.getStatusBar().showMessage(message, self.timeout)
                self.e2LorentzianLineEdit.setList(
                    self.calculation.e2Lorentzian)
                return

        try:
            e2LorentzianMax = float(e2Lorentzian[1])
        except IndexError:
            pass
        else:
            if e2LorentzianMax < 0.1:
                message = 'The broadening cannot be smaller than 0.1.'
                self.getStatusBar().showMessage(message, self.timeout)
                self.e2LorentzianLineEdit.setList(
                    self.calculation.e2Lorentzian)

        try:
            e2LorentzianPivotEnergy = float(e2Lorentzian[2])
        except IndexError:
            pass
        else:
            e2Min = self.calculation.e2Min
            e2Max = self.calculation.e2Max

            if not (e2Min < e2LorentzianPivotEnergy < e2Max):
                message = ('The transition point must lie between the upper '
                           'and lower energy limits.')
                self.getStatusBar().showMessage(message, self.timeout)
                self.e2LorentzianLineEdit.setList(
                    self.calculation.e2Lorentzian)
                return

        self.calculation.e2Lorentzian = list(map(float, e2Lorentzian))

    def updateE2Gaussian(self):
        e2Gaussian = self.e2GaussianLineEdit.getValue()

        if e2Gaussian < 0:
            message = 'The broadening cannot be negative.'
            self.getStatusBar().showMessage(message, self.timeout)
            self.e2GaussianLineEdit.setValue(self.calculation.e2Gaussian)
            return

        self.calculation.e2Gaussian = e2Gaussian

        try:
            index = list(self.resultsView.selectedIndexes())[-1]
        except IndexError:
            return
        else:
            self.resultsModel.replaceItem(index, self.calculation)
            self.plotSelectedCalculations()

    def updatePolarizationsCheckState(self):
        checkedPolarizations = self.polarizationsModel.getCheckState()
        self.calculation.polarizations['checked'] = checkedPolarizations

    def updateScalingFactors(self):
        fk = self.fkLineEdit.getValue()
        gk = self.gkLineEdit.getValue()
        zeta = self.zetaLineEdit.getValue()

        if fk < 0 or gk < 0 or zeta < 0:
            message = 'The scaling factors cannot be negative.'
            self.getStatusBar().showMessage(message, self.timeout)
            self.fkLineEdit.setValue(self.calculation.fk)
            self.gkLineEdit.setValue(self.calculation.gk)
            self.zetaLineEdit.setValue(self.calculation.zeta)
            return

        self.calculation.fk = fk
        self.calculation.gk = gk
        self.calculation.zeta = zeta

        # TODO: This should be already updated to the most recent data.
        # self.calculation.hamiltonianData = self.hamiltonianModel.getModelData() # noqa
        terms = self.calculation.hamiltonianData

        for term in terms:
            if 'Atomic' not in term:
                continue
            configurations = terms[term]
            for configuration in configurations:
                parameters = configurations[configuration]
                for parameter in parameters:
                    value, scaling = parameters[parameter]
                    if parameter.startswith('F'):
                        terms[term][configuration][parameter] = [value, fk]
                    elif parameter.startswith('G'):
                        terms[term][configuration][parameter] = [value, gk]
                    elif parameter.startswith('ζ'):
                        terms[term][configuration][parameter] = [value, zeta]
                    else:
                        continue
        self.hamiltonianModel.updateModelData(self.calculation.hamiltonianData)
        # I have no idea why this is needed. Both views should update after
        # the above function call.
        self.hamiltonianTermsView.viewport().repaint()
        self.hamiltonianParametersView.viewport().repaint()

    def updateNPsisAuto(self):
        nPsisAuto = int(self.nPsisAutoCheckBox.isChecked())

        if nPsisAuto:
            self.nPsisLineEdit.setValue(self.calculation.nPsisMax)
            self.nPsisLineEdit.setEnabled(False)
        else:
            self.nPsisLineEdit.setEnabled(True)

        self.calculation.nPsisAuto = nPsisAuto

    def updateNPsis(self):
        nPsis = self.nPsisLineEdit.getValue()

        if nPsis <= 0:
            message = 'The number of states must be larger than zero.'
            self.getStatusBar().showMessage(message, self.timeout)
            self.nPsisLineEdit.setValue(self.calculation.nPsis)
            return

        if nPsis > self.calculation.nPsisMax:
            message = 'The selected number of states exceeds the maximum.'
            self.getStatusBar().showMessage(message, self.timeout)
            self.nPsisLineEdit.setValue(self.calculation.nPsisMax)
            nPsis = self.calculation.nPsisMax

        self.calculation.nPsis = nPsis

    def updateSyncParameters(self, flag):
        self.hamiltonianModel.setSyncState(flag)

    def updateHamiltonianData(self):
        self.calculation.hamiltonianData = self.hamiltonianModel.getModelData()

    def updateHamiltonianNodeCheckState(self, index, state):
        hamiltonianState = self.hamiltonianModel.getNodesCheckState()
        self.calculation.hamiltonianState = hamiltonianState

        # If needed, enable the configurations.
        term = '{}-Ligands Hybridization'.format(self.calculation.block)
        if term in index.data():
            if state == 0:
                nConfigurations = 1
                self.nConfigurationsLineEdit.setEnabled(False)
            elif state == 2:
                nConfigurations = 2
                self.nConfigurationsLineEdit.setEnabled(True)

            self.nConfigurationsLineEdit.setValue(nConfigurations)
            self.calculation.nConfigurations = nConfigurations

    def updateConfigurations(self, *args):
        nConfigurations = self.nConfigurationsLineEdit.getValue()

        if 'd' in self.calculation.block:
            nConfigurationsMax = 10 - self.calculation.nElectrons + 1
        elif 'f' in self.calculation.block:
            nConfigurationsMax = 14 - self.calculation.nElectrons + 1
        else:
            return

        if nConfigurations > nConfigurationsMax:
            message = 'The maximum number of configurations is {}.'.format(
                nConfigurationsMax)
            self.getStatusBar().showMessage(message, self.timeout)
            self.nConfigurationsLineEdit.setValue(nConfigurationsMax)
            nConfigurations = nConfigurationsMax

        self.calculation.nConfigurations = nConfigurations

    def saveInput(self):
        # TODO: If the user changes a value in a widget without pressing Return
        # or without interacting with another part of the GUI before running
        # the calculation, the values are not updated.

        # Set the verbosity of the calculation.
        self.calculation.verbosity = self.getVerbosity()
        self.calculation.denseBorder = self.getDenseBorder()

        path = self.getCurrentPath()
        try:
            os.chdir(path)
        except OSError as e:
            message = ('The specified folder doesn\'t exist. Use the \'Save '
                       'Input As...\' button to save the input file to an '
                       'alternative location.')
            self.getStatusBar().showMessage(message, 2 * self.timeout)
            raise e

        # The folder might exist, but is not writable.
        try:
            self.calculation.saveInput()
        except (IOError, OSError) as e:
            message = 'Failed to write the Quanty input file.'
            self.getStatusBar().showMessage(message, self.timeout)
            raise e

    def saveInputAs(self):
        # Update the self.calculation
        path, _ = QFileDialog.getSaveFileName(
            self, 'Save Quanty Input',
            os.path.join(self.getCurrentPath(), '{}.lua'.format(
                self.calculation.baseName)), 'Quanty Input File (*.lua)')

        if path:
            basename = os.path.basename(path)
            self.calculation.baseName, _ = os.path.splitext(basename)
            self.setCurrentPath(path)
            try:
                self.saveInput()
            except (IOError, OSError) as e:
                return
            self.updateMainWindowTitle()

    def saveAllCalculationsAs(self):
        path, _ = QFileDialog.getSaveFileName(
            self, 'Save Calculations',
            os.path.join(self.getCurrentPath(), '{}.pkl'.format(
                self.calculation.baseName)), 'Pickle File (*.pkl)')

        if path:
            self.setCurrentPath(path)
            calculations = copy.deepcopy(self.resultsModel.getData())
            calculations.reverse()
            with open(path, 'wb') as p:
                pickle.dump(calculations, p, pickle.HIGHEST_PROTOCOL)

    def saveSelectedCalculationsAs(self):
        path, _ = QFileDialog.getSaveFileName(
            self, 'Save Calculations',
            os.path.join(self.getCurrentPath(), '{}.pkl'.format(
                self.calculation.baseName)), 'Pickle File (*.pkl)')

        if path:
            self.setCurrentPath(path)
            calculations = self.getSelectedCalculationsData()
            calculations.reverse()
            with open(path, 'wb') as p:
                pickle.dump(calculations, p, pickle.HIGHEST_PROTOCOL)

    def resetCalculation(self):
        element = self.elementComboBox.currentText()
        charge = self.chargeComboBox.currentText()
        symmetry = self.symmetryComboBox.currentText()
        experiment = self.experimentComboBox.currentText()
        edge = self.edgeComboBox.currentText()

        self.calculation = QuantyCalculation(
            element=element, charge=charge, symmetry=symmetry,
            experiment=experiment, edge=edge)

        self.populateWidget()
        self.updateMainWindowTitle()

        self.getPlotWidget().reset()
        self.resultsView.selectionModel().clearSelection()

    def removeSelectedCalculations(self):
        self.resultsModel.removeItems(self.resultsView.selectedIndexes())
        if not self.resultsView.selectedIndexes():
            self.getPlotWidget().reset()

    def removeAllCalculations(self):
        self.resultsModel.reset()
        self.getPlotWidget().reset()

    def loadCalculations(self):
        path, _ = QFileDialog.getOpenFileName(
            self, 'Load Calculations',
            self.getCurrentPath(), 'Pickle File (*.pkl)')

        if path:
            self.setCurrentPath(path)
            with open(path, 'rb') as p:
                self.resultsModel.appendItems(pickle.load(p))
            self.updateMainWindowTitle()
            self.quantyToolBox.setCurrentWidget(self.resultsPage)

    def runCalculation(self):
        path = self.getQuantyPath()

        if path:
            command = path
        else:
            message = ('The path to the Quanty executable is not set. '
                       'Please use the preferences menu to set it.')
            self.getStatusBar().showMessage(message, 2 * self.timeout)
            return

        # Test the executable.
        with open(os.devnull, 'w') as f:
            try:
                subprocess.call(command, stdout=f, stderr=f)
            except OSError as e:
                if e.errno == os.errno.ENOENT:
                    message = ('The Quanty executable is not working '
                               'properly. Is the path set correctly?')
                    self.getStatusBar().showMessage(message, 2 * self.timeout)
                    return
                else:
                    raise e

        # Write the input file to disk.
        try:
            self.saveInput()
        except (IOError, OSError) as e:
            return

        self.getPlotWidget().reset()
        self.resultsView.selectionModel().clearSelection()

        # Disable the UI while the calculation is running.
        self.enableWidget(False)

        self.calculation.startingTime = datetime.datetime.now()

        # Run Quanty using QProcess.
        self.process = QProcess()

        self.process.start(command, (self.calculation.baseName + '.lua', ))
        message = (
            'Running "Quanty {}" in {}.'.format(
                self.calculation.baseName + '.lua', os.getcwd()))
        self.getStatusBar().showMessage(message)

        if sys.platform == 'win32' and self.process.waitForStarted():
            self.updateCalculationPushButton()
        else:
            self.process.started.connect(self.updateCalculationPushButton)
        self.process.readyReadStandardOutput.connect(self.handleOutputLogging)
        self.process.finished.connect(self.processCalculation)

    def updateCalculationPushButton(self, type='stop'):
        types = {
            'stop': {
                'iconName': 'stop.svg',
                'buttonText': 'Stop',
                'buttonToolTip': 'Stop Quanty.'},
            'run': {
                'iconName': 'play.svg',
                'buttonText': 'Run',
                'buttonToolTip': 'Run Quanty.'},
        }

        icon = QIcon(resourceFileName(
            'crispy:' + os.path.join('gui', 'icons', types[type]['iconName'])))
        self.calculationPushButton.setIcon(icon)

        self.calculationPushButton.setText(types[type]['buttonText'])
        self.calculationPushButton.setToolTip(types[type]['buttonToolTip'])

        self.calculationPushButton.disconnect()
        if type == 'stop':
            self.calculationPushButton.clicked.connect(self.stopCalculation)
        elif type == 'run':
            self.calculationPushButton.clicked.connect(self.runCalculation)
        else:
            pass

    def stopCalculation(self):
        self.process.kill()
        self.enableWidget(True)

    def processCalculation(self, *args):
        startingTime = self.calculation.startingTime

        # When did I finish?
        endingTime = datetime.datetime.now()
        self.calculation.endingTime = endingTime

        # Re-enable the UI if the calculation has finished.
        self.enableWidget(True)

        # Reset the calculation button.
        self.updateCalculationPushButton('run')

        # Evaluate the exit code and status of the process.
        exitStatus = self.process.exitStatus()
        exitCode = self.process.exitCode()

        if exitStatus == 0 and exitCode == 0:
            message = ('Quanty has finished successfully in ')
            delta = (endingTime - startingTime).total_seconds()
            hours, reminder = divmod(delta, 3600)
            minutes, seconds = divmod(reminder, 60)
            seconds = round(seconds, 2)
            if hours > 0:
                message += '{} hours {} minutes and {} seconds.'.format(
                    hours, minutes, seconds)
            elif minutes > 0:
                message += '{} minutes and {} seconds.'.format(
                    minutes, seconds)
            else:
                message += '{} seconds.'.format(seconds)
            self.getStatusBar().showMessage(message, self.timeout)
        elif exitStatus == 0 and exitCode == 1:
            self.handleErrorLogging()
            message = (
                'Quanty has finished unsuccessfully. '
                'Check the logging window for more details.')
            self.getStatusBar().showMessage(message, self.timeout)
            return
        # exitCode is platform dependent; exitStatus is always 1.
        elif exitStatus == 1:
            message = 'Quanty was stopped.'
            self.getStatusBar().showMessage(message, self.timeout)
            return

        self.calculation.label = '{}{} in {} symmetry, {} {}'.format(
            self.calculation.element, self.calculation.charge,
            self.calculation.symmetry, self.calculation.edge,
            self.calculation.experiment)

        # Read the spectrum.
        f = '{0:s}.spec'.format(self.calculation.baseName)
        try:
            data = np.loadtxt(f, skiprows=5)
        except (OSError, IOError) as e:
            message = 'Failed to read the spectrum file from disk.'
            self.getStatusBar().showMessage(message, self.timeout)
            return

        if self.calculation.experiment == 'RIXS':
            self.calculation.spectrum = data[:, 2::2]
        else:
            self.calculation.spectrum = data[:, 2::2][:, 0]

        # Store the calculation in the model.
        self.resultsModel.appendItems([self.calculation])

        # If the "Hamiltonian Setup" page is currently selected, when the
        # current widget is set to the "Results Page", the former is not
        # displayed. To avoid this I switch first to the "General Setup" page.
        self.quantyToolBox.setCurrentWidget(self.generalPage)
        self.quantyToolBox.setCurrentWidget(self.resultsPage)
        self.resultsView.setFocus()

    def plot(self):
        data = self.calculation.spectrum

        # Check if the data is valid.
        dataMax = np.max(np.abs(data))
        if dataMax < np.finfo(np.float32).eps:
            message = 'The spectrum has very low intensity'
            self.getStatusBar().showMessage(message, self.timeout)
            if self.calculation.experiment != 'RIXS':
                data = np.zeros_like(data)

        if self.calculation.experiment == 'RIXS':
            self.getPlotWidget().setGraphXLabel('Incident Energy (eV)')
            self.getPlotWidget().setGraphYLabel('Energy Transfer (eV)')

            e1Min = self.calculation.e1Min
            e1Max = self.calculation.e1Max
            e1NPoints = self.calculation.e1NPoints

            e2Min = self.calculation.e2Min
            e2Max = self.calculation.e2Max
            e2NPoints = self.calculation.e2NPoints

            xScale = (e1Max - e1Min) / e1NPoints
            yScale = (e2Max - e2Min) / e2NPoints
            scale = (xScale, yScale)

            xOrigin = e1Min
            yOrigin = e2Min
            origin = (xOrigin, yOrigin)

            z = data

            e1Gaussian = self.calculation.e1Gaussian
            e2Gaussian = self.calculation.e2Gaussian

            if e1Gaussian > 0 and e2Gaussian > 0:
                xFwhm = e1Gaussian / xScale
                yFwhm = e2Gaussian / yScale

                fwhm = [xFwhm, yFwhm]
                z = broaden(z, fwhm, 'gaussian')

            self.getPlotWidget().addImage(
                z, origin=origin, scale=scale, reset=False)

        else:
            self.getPlotWidget().setGraphXLabel('Absorption Energy (eV)')
            self.getPlotWidget().setGraphYLabel(
                'Intensity (a.u.)')

            # Rename the x-axis for XPS.
            if 'XPS' in self.calculation.experiment:
                self.getPlotWidget().setGraphXLabel('Binding Energy (eV)')

            e1Min = self.calculation.e1Min
            e1Max = self.calculation.e1Max
            e1NPoints = self.calculation.e1NPoints

            scale = (e1Max - e1Min) / e1NPoints

            e1Gaussian = self.calculation.e1Gaussian

            x = np.linspace(e1Min, e1Max, e1NPoints + 1)
            y = data

            if e1Gaussian > 0:
                fwhm = e1Gaussian / scale
                y = broaden(y, fwhm, 'gaussian')

            legend = self.calculation.legend
            try:
                self.getPlotWidget().addCurve(x, y, legend)
            except AssertionError:
                message = 'The x and y arrays have different lengths.'
                self.getStatusBar().showMessage(message)

    def selectedHamiltonianTermChanged(self):
        index = self.hamiltonianTermsView.currentIndex()
        self.hamiltonianParametersView.setRootIndex(index)

    def showResultsContextMenu(self, position):
        icon = QIcon(resourceFileName(
            'crispy:' + os.path.join('gui', 'icons', 'save.svg')))
        self.saveSelectedCalculationsAsAction = QAction(
            icon, 'Save Selected Calculations As...', self,
            triggered=self.saveSelectedCalculationsAs)
        self.saveAllCalculationsAsAction = QAction(
            icon, 'Save All Calculations As...', self,
            triggered=self.saveAllCalculationsAs)

        icon = QIcon(resourceFileName(
            'crispy:' + os.path.join('gui', 'icons', 'trash.svg')))
        self.removeSelectedCalculationsAction = QAction(
            icon, 'Remove Selected Calculations', self,
            triggered=self.removeSelectedCalculations)
        self.removeAllCalculationsAction = QAction(
            icon, 'Remove All Calculations', self,
            triggered=self.removeAllCalculations)

        icon = QIcon(resourceFileName(
            'crispy:' + os.path.join('gui', 'icons', 'folder-open.svg')))
        self.loadCalculationsAction = QAction(
            icon, 'Load Calculations', self,
            triggered=self.loadCalculations)

        self.resultsContextMenu = QMenu('Results Context Menu', self)
        self.resultsContextMenu.addAction(
            self.saveSelectedCalculationsAsAction)
        self.resultsContextMenu.addAction(
            self.removeSelectedCalculationsAction)
        self.resultsContextMenu.addSeparator()
        self.resultsContextMenu.addAction(self.saveAllCalculationsAsAction)
        self.resultsContextMenu.addAction(self.removeAllCalculationsAction)
        self.resultsContextMenu.addSeparator()
        self.resultsContextMenu.addAction(self.loadCalculationsAction)

        if not self.resultsView.selectedIndexes():
            self.removeSelectedCalculationsAction.setEnabled(False)
            self.saveSelectedCalculationsAsAction.setEnabled(False)

        if not self.resultsModel.modelData:
            self.saveAllCalculationsAsAction.setEnabled(False)
            self.removeAllCalculationsAction.setEnabled(False)

        self.resultsContextMenu.exec_(self.resultsView.mapToGlobal(position))

    def getSelectedCalculationsData(self):
        indexes = self.resultsView.selectedIndexes()
        return self.resultsModel.getModelData(indexes)

    def selectedCalculationsChanged(self, *args):
        self.plotSelectedCalculations()
        self.populateWidget()
        self.updateMainWindowTitle()

    def plotSelectedCalculations(self):
        self.getPlotWidget().reset()
        calculations = self.getSelectedCalculationsData()
        for calculation in calculations:
            if len(calculations) > 1 and calculation.experiment == 'RIXS':
                continue
            self.calculation = calculation
            self.plot()

    def updateResultsViewSelection(self, index, *args):
        selectionModel = self.resultsView.selectionModel()
        selectionModel.clear()
        indexes = self.resultsModel.getRowSiblingsIndexes(index)
        # Block the signals while the complete row is selected. A bit of a
        # hack as the selection model has QItemSelectionMode.Columns can be
        # used, but for some reason it does not work here.
        selectionModel.blockSignals(True)
        for index in indexes:
            selectionModel.select(index, QItemSelectionModel.Select)
        selectionModel.blockSignals(False)
        selection = QItemSelection(index, index)
        selectionModel.selectionChanged.emit(selection, selection)
        self.resultsView.resizeColumnsToContents()
        self.resultsView.setFocus()
        # Update available actions in the context menu if the model has data.
        if not self.resultsModel.modelData:
            self.updateResultsContextMenu(False)
        else:
            self.updateResultsContextMenu(True)

    def updateCalculationName(self, name):
        self.resultsView.resizeColumnsToContents()
        self.calculation.baseName = name
        self.updateMainWindowTitle()

    def handleOutputLogging(self):
        self.process.setReadChannel(QProcess.StandardOutput)
        data = self.process.readAllStandardOutput().data()
        data = data.decode('utf-8').rstrip()
        self.getLoggerWidget().appendPlainText(data)

    def handleErrorLogging(self):
        self.process.setReadChannel(QProcess.StandardError)
        data = self.process.readAllStandardError().data()
        self.getLoggerWidget().appendPlainText(data.decode('utf-8'))

    def updateMainWindowTitle(self):
        title = 'Crispy - {}'.format(self.calculation.baseName + '.lua')
        self.setMainWindowTitle(title)

    def updateResultsContextMenu(self, flag):
        self.parent().quantyMenuUpdate(flag)

    def setMainWindowTitle(self, title):
        self.parent().setWindowTitle(title)

    def getStatusBar(self):
        return self.parent().statusBar()

    def getPlotWidget(self):
        return self.parent().plotWidget

    def getLoggerWidget(self):
        return self.parent().loggerWidget

    def setCurrentPath(self, path):
        path = os.path.dirname(path)
        self.settings.setValue('CurrentPath', path)

    def getCurrentPath(self):
        return self.settings.value('CurrentPath')

    def getQuantyPath(self):
        return self.settings.value('Quanty/Path')

    def getVerbosity(self):
        return self.settings.value('Quanty/Verbosity')

    def getDenseBorder(self):
        return self.settings.value('Quanty/DenseBorder')


class QuantyPreferencesDialog(QDialog):

    def __init__(self, parent, settings=None):
        super(QuantyPreferencesDialog, self).__init__(parent)

        path = resourceFileName(
            'crispy:' + os.path.join('gui', 'uis', 'quanty', 'preferences.ui'))
        loadUi(path, baseinstance=self, package='crispy.gui')

        self.pathBrowsePushButton.clicked.connect(self.setExecutablePath)

        ok = self.buttonBox.button(QDialogButtonBox.Ok)
        ok.clicked.connect(self.acceptSettings)

        cancel = self.buttonBox.button(QDialogButtonBox.Cancel)
        cancel.clicked.connect(self.rejectSettings)

        self.settings = settings
        self.restoreSettings()
        self.saveSettings()

    def _findExecutable(self):
        if sys.platform == 'win32':
            executable = 'Quanty.exe'
        else:
            executable = 'Quanty'

        envPath = QStandardPaths.findExecutable(executable)
        localPath = QStandardPaths.findExecutable(
            executable, [resourceFileName(
                'crispy:' + os.path.join('modules', 'quanty', 'bin'))])

        # Check if Quanty is in the paths defined in the $PATH.
        if envPath:
            path = envPath
        # Check if Quanty is bundled with Crispy.
        elif localPath:
            path = localPath
        else:
            path = None

        return path

    def restoreSettings(self):
        settings = self.settings
        if settings is None:
            return

        settings.beginGroup('Quanty')

        path = settings.value('Path')
        if path is None or not path:
            path = self._findExecutable()
        self.pathLineEdit.setText(path)

        verbosity = settings.value('Verbosity')
        if verbosity is None:
            verbosity = '0x0000'
        self.verbosityLineEdit.setText(verbosity)

        denseBorder = settings.value('DenseBorder')
        if denseBorder is None:
            denseBorder = '50000'
        self.denseBorderLineEdit.setText(denseBorder)

        settings.endGroup()

    def saveSettings(self):
        settings = self.settings
        if settings is None:
            return

        settings.beginGroup('Quanty')
        settings.setValue('Path', self.pathLineEdit.text())
        settings.setValue('Verbosity', self.verbosityLineEdit.text())
        settings.setValue('DenseBorder', self.denseBorderLineEdit.text())
        settings.endGroup()

        settings.sync()

    def acceptSettings(self):
        self.saveSettings()
        self.close()

    def rejectSettings(self):
        self.restoreSettings()
        self.close()

    def setExecutablePath(self):
        path, _ = QFileDialog.getOpenFileName(
            self, 'Select File', os.path.expanduser('~'))

        if path:
            self.pathLineEdit.setText(path)


if __name__ == '__main__':
    pass
