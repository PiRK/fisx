#import numpy as np
#cimport numpy as np
cimport cython

from libcpp.string cimport string as std_string
from libcpp.vector cimport vector as std_vector
from libcpp.map cimport map as std_map

from Element cimport *
    
cdef class PyElement:
    cdef Element *thisptr

    def __cinit__(self, std_string name, z = 0):
        self.thisptr = new Element(name, z)

    def __dealloc__(self):
        del self.thisptr

    def setName(self, std_string name):
        self.thisptr.setName(name)

    def setAtomicNumber(self, int z):
        self.thisptr.setAtomicNumber(z)

    def getAtomicNumber(self):
        return self.thisptr.getAtomicNumber()

    def setBindingEnergies(self, std_map[std_string, double] energies):
        self.thisptr.setBindingEnergies(energies)

    def getBindingEnergies(self):
        return self.thisptr.getBindingEnergies()
    
    def setMassAttenuationCoefficients(self,
                                       std_vector[double] energies,
                                       std_vector[double] photo,
                                       std_vector[double] coherent,
                                       std_vector[double] compton,
                                       std_vector[double] pair):
        self.thisptr.setMassAttenuationCoefficients(energies,
                                                    photo,
                                                    coherent,
                                                    compton,
                                                    pair)
    
    def _getDefaultMassAttenuationCoefficients(self):
        return self.thisptr.getMassAttenuationCoefficients()

    def _getSingleMassAttenuationCoefficients(self, double energy):
        return self.thisptr.getMassAttenuationCoefficients(energy)

    def getMassAttenuationCoefficients(self, energy=None):
        if energy is None:
            return self._getDefaultMassAttenuationCoefficients()
        elif hasattr(energy, "__len__"):
            return self._getMultipleMassAttenuationCoefficients(energy)
        else:
            return self._getMultipleMassAttenuationCoefficients([energy])

    def _getMultipleMassAttenuationCoefficients(self, std_vector[double] energy):
        return self.thisptr.getMassAttenuationCoefficients(energy)
                                       
    def setRadiativeTransitions(self, std_string shell,
                                std_vector[std_string] labels,
                                std_vector[double] values):
        self.thisptr.setRadiativeTransitions(shell, labels, values)

    def getRadiativeTransitions(self, std_string shell):
        return self.thisptr.getRadiativeTransitions(shell)

    def setNonradiativeTransitions(self, std_string shell,
                                   std_vector[std_string] labels,
                                   std_vector[double] values):
        self.thisptr.setNonradiativeTransitions(shell, labels, values)

    def getNonradiativeTransitions(self, std_string shell):
        return self.thisptr.getNonradiativeTransitions(shell)

    def setShellConstants(self, std_string shell,
                          std_map[std_string, double] valuesDict):
        self.thisptr.setShellConstants(shell, valuesDict)

    def getShellConstants(self, std_string shell):
        return self.thisptr.getShellConstants(shell)

    #def getXRayLines(self, std_string shell):
    #    return self.thisptr.getXRayLines(shell)
                          
    def getXRayLinesFromVacancyDistribution(self,
                            std_map[std_string, double] vacancyDict):
        return self.thisptr.getXRayLinesFromVacancyDistribution(\
                                vacancyDict)
    
#import numpy as np
#cimport numpy as np
cimport cython

from libcpp.string cimport string as std_string
from libcpp.vector cimport vector as std_vector
from libcpp.map cimport map as std_map

from Elements cimport *
    
cdef class PyElements:
    cdef Elements *thisptr

    def __cinit__(self, std_string directoryName, 
                        std_string bindingEnergiesFile="",
                        std_string crossSectionsFile=""):
        if len(bindingEnergiesFile):
            self.thisptr = new Elements(directoryName, bindingEnergiesFile)
        else:
            self.thisptr = new Elements(directoryName)
        if len(crossSectionsFile):
            self.thisptr.setMassAttenuationCoefficientsFile(crossSectionsFile)

    def __dealloc__(self):
        del self.thisptr

    def setMassAttenuationCoefficients(self,
                                       std_string element,
                                       std_vector[double] energies,
                                       std_vector[double] photo,
                                       std_vector[double] coherent,
                                       std_vector[double] compton,
                                       std_vector[double] pair):
        self.thisptr.setMassAttenuationCoefficients(element,
                                                    energies,
                                                    photo,
                                                    coherent,
                                                    compton,
                                                    pair)
    def setMassAttenuationCoefficientsFile(self, std_string crossSectionsFile):
        self.thisptr.setMassAttenuationCoefficientsFile(crossSectionsFile)
    
    def _getSingleMassAttenuationCoefficients(self, std_string element,
                                                     double energy):
        return self.thisptr.getMassAttenuationCoefficients(element, energy)

    def _getElementDefaultMassAttenuationCoefficients(self, std_string element):
        return self.thisptr.getMassAttenuationCoefficients(element)

    def getElementMassAttenuationCoefficients(self, element, energy=None):
        if energy is None:
            return self._getElementDefaultMassAttenuationCoefficients(element)            
        elif hasattr(energy, "__len__"):
            return self._getMultipleMassAttenuationCoefficients(element,
                                                                       energy)
        else:
            return self._getMultipleMassAttenuationCoefficients(element,
                                                                       [energy])

    def _getMultipleMassAttenuationCoefficients(self, std_string element,
                                                       std_vector[double] energy):
        return self.thisptr.getMassAttenuationCoefficients(element, energy)
                                       

    def getMassAttenuationCoefficients(self, name, energy=None):
        if hasattr(name, "keys"):
            return self._getMassAttenuationCoefficients(name, energy)
        elif energy is None:
            return self._getElementDefaultMassAttenuationCoefficients(name)
        elif hasattr(energy, "__len__"):
            return self._getMultipleMassAttenuationCoefficients(name, energy)
        else:
            # do not use the "single" version to have always the same signature
            return self._getMultipleMassAttenuationCoefficients(name, [energy])

    def _getMaterialMassAttenuationCoefficients(self, elementDict, energy):
        """
        elementDict is a dictionary of the form:
        elmentDict[key] = fraction where:
            key is the element name
            fraction is the mass fraction of the element.

        WARNING: The library renormalizes in order to make sure the sum of mass
                 fractions is 1.
        """

        if hasattr(energy, "__len__"):
            return self._getMassAttenuationCoefficients(elementDict, energy)
        else:
            return self._getMassAttenuationCoefficients(elementDict, [energy])

    def _getMassAttenuationCoefficients(self, std_map[std_string, double] elementDict,
                                              std_vector[double] energy):
        return self.thisptr.getMassAttenuationCoefficients(elementDict, energy)
#import numpy as np
#cimport numpy as np
cimport cython

from libcpp.string cimport string as std_string
from libcpp.vector cimport vector as std_vector
from libcpp.map cimport map as std_map

from EPDL97 cimport *
    
cdef class PyEPDL97:
    cdef EPDL97 *thisptr

    def __cinit__(self, std_string name):
        self.thisptr = new EPDL97(name)

    def __dealloc__(self):
        del self.thisptr

    def setDataDirectory(self, std_string name):
        self.thisptr.setDataDirectory(name)

    def setBindingEnergies(self, int z, std_map[std_string, double] energies):
        self.thisptr.setBindingEnergies(z, energies)

    def getBindingEnergies(self, int z):
        return self.thisptr.getBindingEnergies(z)
    
    def getMassAttenuationCoefficients(self, z, energy=None):
        if energy is None:
            return self._getDefaultMassAttenuationCoefficients(z)            
        elif hasattr(energy, "__len__"):
            return self._getMultipleMassAttenuationCoefficients(z, energy)
        else:
            return self._getMultipleMassAttenuationCoefficients(z, [energy])

    def _getDefaultMassAttenuationCoefficients(self, int z):
        return self.thisptr.getMassAttenuationCoefficients(z)

    def _getSingleMassAttenuationCoefficients(self, int z, double energy):
        return self.thisptr.getMassAttenuationCoefficients(z, energy)

    def _getMultipleMassAttenuationCoefficients(self, int z, std_vector[double] energy):
        return self.thisptr.getMassAttenuationCoefficients(z, energy)
                                       
    def getPhotoelectricWeights(self, z, energy):
        if hasattr(energy, "__len__"):
            return self._getMultiplePhotoelectricWeights(z, energy)
        else:
            return self._getMultiplePhotoelectricWeights(z, [energy])

    def _getSinglePhotoelectricWeights(self, int z, double energy):
        return self.thisptr.getPhotoelectricWeights(z, energy)

    def _getMultiplePhotoelectricWeights(self, int z, std_vector[double] energy):
        return self.thisptr.getPhotoelectricWeights(z, energy)
#import numpy as np
#cimport numpy as np
cimport cython

#from libcpp.string cimport string as std_string
#from libcpp.vector cimport vector as std_vector
#from libcpp.map cimport map as std_map

from Shell cimport *

cdef class PyShell:
    cdef Shell *thisptr

    def __cinit__(self, name):
        self.thisptr = new Shell(name)

    def __dealloc__(self):
        del self.thisptr

    def setRadiativeTransitions(self, std_vector[std_string] transitions, std_vector[double] values):
        self.thisptr.setRadiativeTransitions(transitions, values)

    def setNonradiativeTransitions(self, std_vector[std_string] transitions, std_vector[double] values):
        self.thisptr.setNonradiativeTransitions(transitions, values)

    def getAugerRatios(self):
        return self.thisptr.getAugerRatios()

    def getCosterKronigRatios(self):
        return self.thisptr.getCosterKronigRatios()

    def getFluorescenceRatios(self):
        return self.thisptr.getFluorescenceRatios()

    def getRadiativeTransitions(self):
        return self.thisptr.getRadiativeTransitions()

    def getNonradiativeTransitions(self):
        return self.thisptr.getNonradiativeTransitions()

    def getDirectVacancyTransferRatios(self, std_string subshell):
        return self.thisptr.getDirectVacancyTransferRatios(subshell)

    def setShellConstants(self, std_map[std_string, double] shellConstants):
        self.thisptr.setShellConstants(shellConstants)

    def getShellConstants(self):
        return self.thisptr.getShellConstants()
#import numpy as np
#cimport numpy as np
cimport cython

from libcpp.string cimport string as std_string
from libcpp.vector cimport vector as std_vector
from libcpp.map cimport map as std_map

from SimpleIni cimport *
    
cdef class PySimpleIni:
    cdef SimpleIni *thisptr

    def __cinit__(self, std_string name):
        self.thisptr = new SimpleIni(name)

    def __dealloc__(self):
        del self.thisptr

    def getKeys(self):
        return self.thisptr.getKeys()

    def readKey(self, std_string key):
        return self.thisptr.readKey(key)
#import numpy as np
#cimport numpy as np
cimport cython

from libcpp.string cimport string as std_string
from libcpp.vector cimport vector as std_vector
from libcpp.map cimport map as std_map

from SimpleSpecfile cimport *
    
cdef class PySimpleSpecfile:
    cdef SimpleSpecfile *thisptr

    def __cinit__(self, std_string name):
        self.thisptr = new SimpleSpecfile(name)

    def __dealloc__(self):
        del self.thisptr

    def getNumberOfScans(self):
        return self.thisptr.getNumberOfScans()

    #def getScanHeader(self, int scanIndex):
    #    return self.thisptr.getScanHeader(scanIndex)

    def getScanLabels(self, int scanIndex):
        return self.thisptr.getScanLabels(scanIndex)

    def getScanData(self, int scanIndex):
        return self.thisptr.getScanData(scanIndex)
