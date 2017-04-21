%% Instrument Connection

% Find a serial port object.
obj1 = instrfind('Type', 'serial', 'Port', 'COM11', 'Tag', '');

% Create the serial port object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = serial('COM11');
else
    fclose(obj1);
    obj1 = obj1(1);
end

% Connect to instrument object, obj1.
fopen(obj1);

%% Instrument Configuration and Control

% Communicating with instrument object, obj1.
data1 = fscanf(obj1)
while 1
fprintf(obj1, '255,255,0')
pause(.1)
data5 = fscanf(obj1)
fprintf(obj1, '255,0,255')
pause(.1)
data5 = fscanf(obj1)
fprintf(obj1, '0,255,255')
pause(.1)
data5 = fscanf(obj1)
fprintf(obj1, '255,0,255')
pause(.1)
data5 = fscanf(obj1)
end