function name = table2str(MethodNameSeleted)
    if size(MethodNameSeleted,2) == 1
        name = MethodNameSeleted{1,1};
    else
        name = MethodNameSeleted{1,1};
        for i = 2 : size(MethodNameSeleted,2)
            temp2 = MethodNameSeleted{1,i};
            if ismissing(temp2)
                return
            else
                name = strcat(name, "→");
                name = strcat(name, temp2);
            end
            
        end
    end
    
end