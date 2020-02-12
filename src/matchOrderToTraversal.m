
% Author(s): Claudia Latella, 2017
% Dynamic Interaction Control, Istituto Italiano di Tecnologia


function [ orderedData ] = matchOrderToTraversal( originalOrder, originalData, finalOrder )
orderedData = zeros(size(originalData)); 
for i = 1 : length(finalOrder)
    index = indexOfString (originalOrder, finalOrder{i});
    orderedData(i,:) = originalData(index,:);
end
end

function [ index ] = indexOfString ( cellArray, stringName)
  index = -1;
  for i = 1 : length(cellArray)
      if strcmp (cellArray{i}, stringName)
          index = i;
          break;
      end
  end
end