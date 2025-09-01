import numpy as np
def add_fiducials_along_line(line_name, num_intermediate_markers):
    """
    Adds fiducials along a line in 3D Slicer based on the specified number of intermediate markers.
    Labels points as line_name1, line_name2, ..., line_name(N+2), where N is the number of intermediate markers.
    Fiducials inherit display properties from the line node, and the fiducial node is named after the line.
    After adding the fiducials, the original line node is deleted from the scene.

    Parameters:
    - line_name: str, name of the line node in the scene
    - num_intermediate_markers: int, number of intermediate points between start and end
    """
    import numpy as np  # Ensure numpy is imported

    # Get the line node by name
    lineNode = slicer.util.getNode(line_name)
    
    # Ensure there is a valid line with at least two control points
    if not lineNode or lineNode.GetNumberOfControlPoints() < 2:
        raise ValueError("A valid line node with at least two control points is required.")
    
    # Retrieve start and end points of the line
    startPoint = np.array(lineNode.GetNthControlPointPositionVector(0))
    endPoint = np.array(lineNode.GetNthControlPointPositionVector(1))
    
    # Calculate vector and segment length
    vector = endPoint - startPoint
    unit_vector = vector / np.linalg.norm(vector)  # Normalize the vector
    segment_length = np.linalg.norm(vector) / (num_intermediate_markers + 1)  # Equal segment length
    
    # Create a new fiducial node to hold the markers, named after the line
    fiducialNodeName = line_name  # Use the same name as the line
    fiducialNode = slicer.mrmlScene.AddNewNodeByClass("vtkMRMLMarkupsFiducialNode", fiducialNodeName)
    
    # Copy display properties from the line node
    lineDisplayNode = lineNode.GetDisplayNode()
    fiducialDisplayNode = fiducialNode.GetDisplayNode()
    
    # Manually copy relevant display properties
    fiducialDisplayNode.SetGlyphScale(lineDisplayNode.GetGlyphScale())
    fiducialDisplayNode.SetGlyphType(lineDisplayNode.GetGlyphType())
    fiducialDisplayNode.SetColor(lineDisplayNode.GetColor())
    fiducialDisplayNode.SetSelectedColor(lineDisplayNode.GetSelectedColor())
    fiducialDisplayNode.SetOpacity(lineDisplayNode.GetOpacity())
    fiducialDisplayNode.SetUseGlyphScale(lineDisplayNode.GetUseGlyphScale())
    fiducialDisplayNode.SetGlyphSize(lineDisplayNode.GetGlyphSize())
    fiducialDisplayNode.SetTextScale(lineDisplayNode.GetTextScale())
    fiducialDisplayNode.SetSliceProjection(lineDisplayNode.GetSliceProjection())
    
    # Set glyph size to absolute and specify the size
    fiducialDisplayNode.SetUseGlyphScale(False)  # Use absolute glyph size
    fiducialDisplayNode.SetGlyphSize(1.0)        # Set glyph size to 1.5 mm
    
    # Add the first point (startPoint) as line_name1
    fiducialNode.AddFiducial(*startPoint)
    fiducialNode.SetNthFiducialLabel(0, f"{line_name}1")
    
    # Add intermediate fiducials along the line with appropriate naming
    for i in range(1, num_intermediate_markers + 1):
        position = startPoint + i * segment_length * unit_vector
        fiducial_name = f"{line_name}{i+1}"  # Intermediate points from line_name2 up to line_name(N+1)
        fiducialNode.AddFiducial(*position)
        fiducialNode.SetNthFiducialLabel(i, fiducial_name)
    
    # Add the last point (endPoint) as line_name(N+2)
    fiducialNode.AddFiducial(*endPoint)
    fiducialNode.SetNthFiducialLabel(num_intermediate_markers + 1, f"{line_name}{num_intermediate_markers + 2}")

    # Remove the original line node from the scene
    #slicer.mrmlScene.RemoveNode(lineNode)


import slicer
import os
import csv
import vtk

def export_all_fiducials(mainPath):
    """
    Exports all fiducials in the 3D Slicer scene to a CSV file.
    The output path is constructed using the mainPath and subject ID extracted from the first node under the scene in the hierarchy.
    """
    fiducial_data = []

    # Get the subject hierarchy node
    shNode = slicer.vtkMRMLSubjectHierarchyNode.GetSubjectHierarchyNode(slicer.mrmlScene)
    if not shNode:
        print("No subject hierarchy node found in the scene.")
        return

    # Get the root item ID (scene root)
    rootItemID = shNode.GetSceneItemID()

    # Get the children of the root item (first level under Scene)
    childItemIDs = vtk.vtkIdList()
    shNode.GetItemChildren(rootItemID, childItemIDs)

    if childItemIDs.GetNumberOfIds() == 0:
        print("No child items found under the scene root.")
        return

    # Get the first child item ID
    firstChildItemID = childItemIDs.GetId(0)

    # Get the associated data node
    mainNode = shNode.GetItemDataNode(firstChildItemID)
    if not mainNode:
        print("No data node associated with the first child item.")
        return

    node_name = mainNode.GetName()

    # Extract the subject ID from the node name (e.g., 's02' from 's02_mainNode')
    subject = node_name.split('_')[0]  # Adjust the splitting logic based on your naming convention

    # Construct the output path using mainPath and subject ID
    subject_folder = os.path.join(mainPath, subject)
    if not os.path.exists(subject_folder):
        os.makedirs(subject_folder)
    output_path = os.path.join(subject_folder, f"{subject}_fiducials.csv")

    # Loop through all fiducial nodes and collect fiducial data
    fiducial_nodes = slicer.mrmlScene.GetNodesByClass("vtkMRMLMarkupsFiducialNode")
    if fiducial_nodes.GetNumberOfItems() == 0:
        print("No fiducial nodes found in the scene.")
        return

    for i in range(fiducial_nodes.GetNumberOfItems()):
        fiducial_node = fiducial_nodes.GetItemAsObject(i)
        
        # Loop through each fiducial in the node
        for j in range(fiducial_node.GetNumberOfFiducials()):
            label = fiducial_node.GetNthFiducialLabel(j)
            position = [0.0, 0.0, 0.0]
            fiducial_node.GetNthFiducialPosition(j, position)
            fiducial_data.append([label, position[0], position[1], position[2]])

    # Save to CSV file
    with open(output_path, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["Label", "X", "Y", "Z"])
        writer.writerows(fiducial_data)

    print(f"Fiducials exported to {output_path}")

