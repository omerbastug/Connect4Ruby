module WinCheck
    def vertical(matrix,i,j)
        row = matrix.length

        topPointer = i   
        botPointer = i

        while topPointer < row - 1  and matrix[topPointer+1]!=nil and matrix[topPointer+1][j] == matrix[i][j] 
            topPointer +=1;
        end

        while botPointer >= 1  and matrix[botPointer-1]!=nil and matrix[botPointer-1][j] == matrix[i][j] 
            botPointer -=1;
        end

        if (topPointer-botPointer).abs >= 3 then
            return {
                :i => botPointer,
                :j => j,
                :direction => "v"
            }
        else 
            return nil
        end
    end
    
    def horizontal(matrix, i, j)
        col = matrix[0].length

        leftPointer = j   
        rightPointer = j

        while rightPointer < col - 1 and matrix[i]!=nil and matrix[i][rightPointer+1] == matrix[i][j] 
            rightPointer +=1;
        end

        while leftPointer >= 1  and matrix[i]!=nil and matrix[i][leftPointer-1] == matrix[i][j] 
            leftPointer -=1;
        end

        if (rightPointer-leftPointer).abs >= 3 then
            return {
                :i => i,
                :j => leftPointer,
                :direction => "h"
            }
        else 
            return nil
        end
    end
    
    def diagonalDown(matrix,i,j)
        row = matrix.length
        col =  matrix[0].length
        #col = 7

        lowerPointerx = i   
        lowerPointery = j

        upperPointerx = i   
        upperPointery = j

        while upperPointerx > 0 and upperPointery < col - 1 and matrix[upperPointerx+1]!=nil and  matrix[upperPointerx-1][upperPointery+1] == matrix[i][j] 
            upperPointerx -=1
            upperPointery +=1
        end

        while lowerPointerx < row -1 and  lowerPointery > 0 and matrix[lowerPointerx-1]!=nil and matrix[lowerPointerx+1][lowerPointery-1] == matrix[i][j] 
            lowerPointerx +=1
            lowerPointery -=1
        end

        dist = Math.sqrt((upperPointerx - lowerPointerx)**2 + (lowerPointery - upperPointery)**2).floor

        if dist >= 3 then
            return {
                :i => lowerPointerx,
                :j => lowerPointery,
                :direction => "du"
            }
        else 
            return nil
        end
    end

    def diagonalUp(matrix,i,j)
        row = matrix.length
        col =  matrix[0].length
        #col = 7

        lowerPointerx = i   
        lowerPointery = j

        upperPointerx = i   
        upperPointery = j

        while upperPointerx > 0 and upperPointery > 0 and matrix[upperPointerx-1]!=nil and  matrix[upperPointerx-1][upperPointery-1] == matrix[i][j] 
            upperPointerx -=1
            upperPointery -=1
        end

        while lowerPointerx < col -1 and  lowerPointery < row -1 and matrix[lowerPointerx+1]!=nil and matrix[lowerPointerx+1][lowerPointery+1] == matrix[i][j] 
            lowerPointerx +=1
            lowerPointery +=1
        end

        dist = Math.sqrt((upperPointerx - lowerPointerx)**2 + (lowerPointery - upperPointery)**2).floor

        if dist >= 3 then
            return {
                :i => upperPointerx,
                :j => upperPointery,
                :direction => "dd"
            }
        else 
            return nil
        end
    end
end

# def verticalCheck(streak)
    #     0.upto(@col-1) do |i|
    #         0.upto(@row-1) do |j|
    #             element = @matrix[j][i]
    #             win = streak.next(
    #                 element,
    #                 "v",  # vertical
    #                 j,
    #                 i
    #             )
    #             if win != -1 then
    #                 return win
    #             end
    #         end
    #     end
    #     return -1
    # end

    # def horizontalCheck(streak)
    #     0.upto(@row-1) do |i|
    #         0.upto(@col-1) do |j|
    #             element = @matrix[i][j]
    #             win = streak.next(
    #                 element,
    #                 "h",  # vertical
    #                 i,
    #                 j
    #             )
    #             if win != -1 then
    #                 return win
    #             end
    #         end
    #     end
    #     return -1
    # end