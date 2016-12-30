function varargout = Settings(varargin)
%% Initialization code.
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Settings_OpeningFcn, ...
    'gui_OutputFcn',  @Settings_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code

function Settings_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
if strcmp(get(hObject,'Visible'),'off')
    initial = imread('initialsp1.png');                              % application logo print in axes1
    imagesc(initial);
    axis off;
end

function varargout = Settings_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
    case 1
        refimg = imread('refcam1.jpg');
        imagesc(refimg)
        axis off;
    case 2
        refimg = imread('refcam2.jpg');
        imagesc(refimg)
        axis off;
end

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', {'Camera1', 'Camera2'});


%%% Button Update Reference Image
% this will start the selected camera, take 3 consecutive images and sum
% them all to form a single image as reference image and save it
function pushbutton1_Callback(hObject, eventdata, handles)
axes(handles.axes1);
cla;
load('slots.mat');
popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
    case 1
        try
            %vid = ipcam('http://192.168.0.2:8080/video');
            vid = ipcam(camurl1);
        catch E
            msgbox({'Configure The Cam Correctly!',' ',E.message},'CAM INFO')
        end
        
    case 2
        try
            %vid = ipcam('http://192.168.0.3:8080/video');
            vid = ipcam(camurl2);
        catch E
            msgbox({'Configure The Cam Correctly!',' ',E.message},'CAM INFO')
        end
end
guidata(hObject, handles);
img = snapshot(vid);
handles.vid=vid;
hImage = image( zeros(size(img)) );
preview(handles.vid, hImage)
pause(5)
img1 = snapshot(vid);        pause(1)
img2 = snapshot(vid);        pause(1)
img3 = snapshot(vid);        pause(1)
closePreview(vid)
bk_img = double(img1)+double(img2)+double(img3);
mean_img =  uint8(bk_img / 3);
switch popup_sel_index
    case 1
        imwrite(mean_img,'refcam1.jpg','jpg');
    case 2
        imwrite(mean_img,'refcam2.jpg','jpg');
end
imagesc(mean_img);
axis off;


%%% Button Add slots
% This will openup the saved refence image and will provide with an option
% to select the parking spots
function pushbutton2_Callback(hObject, eventdata, handles)
popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
    case 1
        imageObj = imread('refcam1.jpg');
        imageHandle = imagesc(imageObj);
        axis off;
        [clicked_col clicked_row rgb_info] = impixel
        corcam1 = zeros(length(clicked_col),2);
        if ~isempty(clicked_col)
            for x=1:1:length(clicked_col)
                corcam1(x,1) = clicked_col(x);
                corcam1(x,2) = clicked_row(x);
            end
        end
        save('slots.mat', 'corcam1','-append')
        set(handles.listbox1, 'String',num2str(corcam1(:,:)));
        
    case 2
        imageObj = imread('refcam2.jpg');
        imageHandle = imagesc(imageObj);
        axis off;
        [clicked_col clicked_row rgb_info] = impixel
        corcam2 = zeros(length(clicked_col),2);
        if ~isempty(clicked_col)
            for x=1:1:length(clicked_col)
                corcam2(x,1) = clicked_col(x);
                corcam2(x,2) = clicked_row(x);
            end
        end
        save('slots.mat', 'corcam2','-append')
        set(handles.listbox1, 'String',num2str(corcam2(:,:)));
        
end

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%% Button Camera Configuration
% will jump to cameraconfig function
function pushbutton3_Callback(hObject, eventdata, handles)
cameraconfig()


%%% Parameter Tweaking options
% will provide editboxes to typein parameters and will save them after
% pressing save button
function edit1_Callback(hObject, eventdata, handles)
% does nothing

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
a=load('slots.mat', 'hsize');
set(hObject,'String',num2str(a.hsize));


function edit2_Callback(hObject, eventdata, handles)
% does nothing

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
a=load('slots.mat', 'sigma');
set(hObject,'String',num2str(a.sigma));


function edit3_Callback(hObject, eventdata, handles)
% does nothing

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
a=load('slots.mat', 'eliminate');
set(hObject,'String',num2str(a.eliminate));


function edit4_Callback(hObject, eventdata, handles)
% does nothing

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
a=load('slots.mat', 'thres');
set(hObject,'String',num2str(a.thres));


% Save button
function pushbutton4_Callback(hObject, eventdata, handles)
hsize = get(handles.edit1,'String');
save('slots.mat', 'hsize','-append')
sigma = get(handles.edit2,'String');
save('slots.mat', 'sigma','-append')
eliminate = get(handles.edit3,'String');
save('slots.mat', 'eliminate','-append')
thres = get(handles.edit4,'String');
save('slots.mat', 'thres','-append')
