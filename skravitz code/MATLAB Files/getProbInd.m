function probInd = getProbInd(output,intervals)


if output < intervals(1)
    probInd = 1;
    return;
else
    for interInd=2:length(intervals)
        if output < intervals(interInd)
            probInd = interInd;
            return;
        end
    end
end

probInd = length(intervals)+1;