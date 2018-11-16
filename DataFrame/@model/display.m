function display(m)
if isempty(m.mod), m.creator='Empty'; end
fprintf('\n%s model created %s w/ %d independent variables\n\n',m.creator,datestr(m.creation,0),length(m.indepvars));
