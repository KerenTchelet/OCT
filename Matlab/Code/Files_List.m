
% returns the list of all %choose format % files in DataFolder and it's subfolder
function FList=Files_List(DataFolder,format)
DirContents=dir(DataFolder);
FList=[];

if(strcmpi(computer,'PCWIN') || strcmpi(computer,'PCWIN64'))
    NameSeperator='\';
elseif(strcmpi(computer,'GLNX86') || strcmpi(computer,'GLNXA86'))
    NameSeperator='/';
end

extList={format};
for i=1:numel(DirContents)
    if(~(strcmpi(DirContents(i).name,'.') || strcmpi(DirContents(i).name,'..')))
        if(~DirContents(i).isdir)
            extension=DirContents(i).name(end-2:end);
            if(numel(find(strcmpi(extension,extList)))~=0)
                FList=cat(1,FList,{[DataFolder,NameSeperator,DirContents(i).name]});
            end
        else
            getlist=ReadImageNames([DataFolder,NameSeperator,DirContents(i).name]);
            FList=cat(1,FList,getlist);
        end
    end
end
end
