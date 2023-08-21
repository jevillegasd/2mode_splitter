function data = read_csv(die, circuit, output,  ref)
    if nargin == 3
        ref = "";
    end
    data = {};
    
    file = die + "\Optical_spectrum_IL_" + output +'_'+ circuit;
    fstruct = dir('*'+file+'*.csv');
    
    for idx_file = 1: length(fstruct)
        fname = ""+fstruct(idx_file).folder + '\' + fstruct(idx_file).name;
        
        opts = detectImportOptions(fname);
        opts.SelectedVariableNames = opts.VariableNames([1 2]);
        Table = readtable(fname,opts);
        wav = Table.(1);
        P = Table.(2);
        
        %% Retreive the data for auxiliary variables
        params = read_params(fname, opts.DataLines(1)-2-1);
       
       % all = readtable(fname);
        
        %% Normalize to a different file:
        if ref ~= ""
            file_ref = die + "\Optical_spectrum_IL_" + ref ;
            fstruct_ref = dir('*'+file_ref+'*.csv');
            if length(fstruct_ref)>1
                print("More than one refrence file found, using " + fstruct_ref(1).name)
            end
            fname = ""+fstruct_ref(1).folder + '\' + fstruct_ref(1).name;
            opts = detectImportOptions(fname);
            Table = readtable(fname,opts);
            
            wav2 = Table.(1);
            P2 = Table.(2);
    
            if length(wav2) ~= length(wav)
                P2 = interp_doublearray(wav2,P2, wav, 5);
            end
    
            P = P - P2;
        end

        % Return strcture
        obj.wav = wav;
        obj.P = P;
        obj.params = params;
        data{idx_file} = obj;
    end
end


function newP = interp_doublearray(x,y, new_x, wsize)
    newP = []; sta = 1; sto = wsize;
    dx = new_x(2)-new_x(1);

    for i = 1:wsize:length(new_x)
        newx = new_x(i:i+wsize-1);

        % Find double values that approximate each other
        ind = abs(x-new_x(i))<dx/10;
        nsta = find(ind);
        ind = abs(x-newx(end))<dx/10;
        nsto = find(ind);
        if ~isempty(nsta) 
            sta = nsta;
        end 
        if ~isempty(nsto)
            sto = nsto;
        end

        % Make a linear interpolation over the new xs
        [Pol,R] = polyfit(x(sta:sto),y(sta:sto),3);
        [fity,~] = polyval(Pol,newx,R);
        newP = [newP ; fity]    ;
    end
end

function params = read_params(fname, max_idx)
    if nargin == 1
        opts = detectImportOptions(fname);
        max_idx = opts.DataLines(1)-2-1;
    end
    fileID = fopen(fname,'r');
    str_params = textscan(fileID,'%s',max_idx,'HeaderLines', 2,'Delimiter', "|",'EndOfLine',[char(13), char(10)]);
    str_params = str_params{1};
    for i = 1:length(str_params)
        cs= regexp(str_params{i},':','split','once');
        fields{i} = replace(replace(cs{1},' ',''),'ExperimentalCondition',''); %Field names cannot have spaces
        values{i} = strtrim(cs{2});
    end
    fclose(fileID);
    fields = replace(fields,' ','');
    params = cell2struct(values,fields,2);
end
