function m = spxy(X,y,Ncal)
    dminmax = zeros(1,Ncal); % Inicializes the vector of minimum distances.
    M= size(X,1); % Number of objects
    samples = 1:M;
    Dx = zeros(M,M); % Inicializes the matrix of X-distances.
    Dy = zeros(M,M); % Inicializes the matriz de y-distances.
    for i = 1:M-1
        xa =X(i,:);
        ya = y(i,:);
        for j=i+1:M
            xb =X(j,:);
            yb = y(j,:);
            Dx(i, j) = norm(xa-xb);
            Dy(i, j) = norm(ya-yb);
        end
    end
    Dxmax =max(max(Dx));
    Dymax =max(max(Dy));
    D=Dx/Dxmax +Dy/Dymax; % Combines the X and y distances.
    % D is an upper triangular matrix.
    % D(i,j) is the distance between objects i and j (j > i).
    [maxD,index_row] =max(D);
    % maxD is a row vector containing the largest element for each column of D.
    % index row is the row in which the largest element of the column if found.
    [dummy,index_column] =max(maxD);
    % index column is the column containing the largest element of matrix D.
    m(1) = index_row(index_column);
    m(2) = index_column;
    for i = 3:Ncal
        pool = setdiff(samples,m);
        % Pool is the index set of the samples that have not been selected yet.
        dmin = zeros(1,M-i + 1);
        % dmin will store the minimum distance of each sample in ¡°pool¡± with respect to the previously selected samples.
        for j = 1:(M-i+1)
            indexa = pool(j);
            d = zeros(1,i-1);
                for k = 1:(i-1)
                    indexb =m(k);
                    if indexa < indexb
                    d(k) =D(indexa,indexb);
                    else
                    d(k) =D(indexb,indexa);
                    end
                end
            dmin(j) =min(d);
        end
        % At each iteration, the sample with the largest dmin value is selected.
        [dummy,index] =max(dmin);
        m(i) = pool(index);
    end