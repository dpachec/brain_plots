import numpy as np
import slicer
import SampleData
import vtk

def getSampleVolume():
    # Check if there is already a volume in the scene
    volumeNodes = slicer.mrmlScene.GetNodesByClass('vtkMRMLScalarVolumeNode')
    volumeNodes.UnRegister(None)  # Prevent memory leaks
    if volumeNodes.GetNumberOfItems() == 1:
        # If there's only one volume node, return it
        return volumeNodes.GetItemAsObject(0)
    else:
        # If no volume or multiple volumes are present, download MRHead as a sample volume
        sampleDataLogic = SampleData.SampleDataLogic()
        volumeNode = sampleDataLogic.downloadMRHead()
        return volumeNode


def getMatrixToACPC(ac, pc, ih):
    # Calculate AC-PC transformation matrix
    pcAc = ac - pc
    yAxis = pcAc / np.linalg.norm(pcAc)
    acIhDir = ih - ac
    xAxis = np.cross(yAxis, acIhDir)
    xAxis /= np.linalg.norm(xAxis)
    zAxis = np.cross(xAxis, yAxis)
    rotation = np.vstack([xAxis, yAxis, zAxis])
    translation = -np.dot(rotation, ac)
    matrix = np.eye(4)
    matrix[:3, :3] = rotation
    matrix[:3, 3] = translation
    return matrix

def getTransformNodeFromNumpyMatrix(matrix, name=None):
    # Create transform node from matrix
    vtkMatrix = vtk.vtkMatrix4x4()
    for row in range(4):
        for col in range(4):
            vtkMatrix.SetElement(row, col, matrix[row, col])
    transformNode = slicer.mrmlScene.AddNewNodeByClass('vtkMRMLLinearTransformNode')
    if name:
        transformNode.SetName(name)
    transformNode.SetAndObserveMatrixTransformToParent(vtkMatrix)
    return transformNode

# Get markups node with fiducials
markupsNode = slicer.util.getNode('AC-PC-IH')

# Retrieve updated coordinates of each fiducial
ac = np.zeros(3)
pc = np.zeros(3)
ih = np.zeros(3)
markupsNode.GetNthFiducialPosition(0, ac)  # AC
markupsNode.GetNthFiducialPosition(1, pc)  # PC
markupsNode.GetNthFiducialPosition(2, ih)  # IH

print(f"AC: {ac}, PC: {pc}, IH: {ih}")

# Load sample volume and compute transformation
volumeNode = getSampleVolume()
matrix = getMatrixToACPC(ac, pc, ih)
transformNode = getTransformNodeFromNumpyMatrix(matrix, name='World to ACPC')

# Apply transform to volume and fiducials
volumeNode.SetAndObserveTransformNodeID(transformNode.GetID())
markupsNode.SetAndObserveTransformNodeID(transformNode.GetID())

# Fit image to slices and center views on AC
applicationLogic = slicer.app.applicationLogic()
applicationLogic.FitSliceToAll()
markupsLogic = slicer.modules.markups.logic()
markupsLogic.JumpSlicesToNthPointInMarkup(markupsNode.GetID(), 0)  # AC point index




