import numpy as np
import slicer

# Define initial positions (you can update these after running the script)
ac = np.array([0, 0, 0])
pc = np.array([0, 0, 0])
ih = np.array([0, 0, 0])

# Create markups node with AC, PC, and an interhemispheric point
markupsNode = slicer.mrmlScene.AddNewNodeByClass('vtkMRMLMarkupsFiducialNode')
markupsNode.SetName('AC-PC-IH')
markupsNode.AddFiducialFromArray(ac, 'AC')
markupsNode.AddFiducialFromArray(pc, 'PC')
markupsNode.AddFiducialFromArray(ih, 'IH')

print("Fiducials created. You can now adjust their positions in the Slicer GUI.")
