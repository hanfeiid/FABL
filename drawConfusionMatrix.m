function drawConfusionMatrix(data, label)
% data is nXn confusion matrix with percentage representation
% label is the cell of size n

% months = {'Jan'; 'Feb'; 'Mar'; 'Apr'; 'May'; 'Jun'; ... 
%     'Jul'; 'Aug'; 'September'; 'Oct'; 'Nov'; 'Dec'};
% n_type = 8;
% data = rand(n_type, n_type);
% label = months(1:n_type);

n_type = length(label);

size_data = size(data);
if size_data(1) ~= n_type || size_data(2) ~= n_type
    error('drawConfusionMatrix: data and label dimensions do not match');
end

figure('Color',[1 1 1]);
imagesc(data);
colorbar;
colormap(jet);


% Set the X-Tick locations so that every other month is labeled.
Xt = 1:n_type;
Yt = 1:n_type;
% set(gca,'XTick',Xt);
set(gca,'YTick',Xt);
axis off;
axis equal;

ax = axis; % Current axis limits
axis(axis); % Set the axis limit modes (e.g. XLimMode) to manual
Yl = ax(3:4); % Y-axis limits


% Place the text labels
% Note: Yl(1) show label ticks on top. Yl(2) show on bottom.
% set x labels
t = text(Xt,Yl(2)*ones(1,length(Xt)),label);
set(t,'HorizontalAlignment','right','VerticalAlignment','top', 'Rotation',45);

t = text(Xt(1)*ones(1,length(Xt))-0.7,Yt,label);
set(t,'HorizontalAlignment','right','VerticalAlignment','middle', 'Rotation',0);

textalign = { 'VerticalAlignment','middle', 'HorizontalAlignment','center', 'color', [1 1 1] };
for i = 1:n_type
    for j = 1:n_type
        label = sprintf('%.2f',data(i,j));
        label = label(2:length(label));
        if data(i,j) == 1
            text(j,i,'1.00', textalign{:});
        elseif data(i,j)>0 && data(i,j) < 1
            text(j,i,label, textalign{:});
        end
    end
end