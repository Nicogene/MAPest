%% Preliminaries

opts.singleVariableTuning = false;
opts.totalVariableTuning  = true;

% close all;
nrOfDoFs = double(humanModel.getNrOfDOFs);

close all;
bucket.pathToCovarianceTuningData   = fullfile(bucket.pathToTask,'covarianceTuning');

% Load y_sim_linAcc
y_sim_linAcc_power1 = load(fullfile(bucket.pathToCovarianceTuningData,'processed_SOTtask2_power1/y_sim_linAcc.mat'),'y_sim_linAcc');
y_sim_linAcc_power2 = load(fullfile(bucket.pathToCovarianceTuningData,'processed_SOTtask2_power2/y_sim_linAcc.mat'),'y_sim_linAcc');
y_sim_linAcc_power3 = load(fullfile(bucket.pathToCovarianceTuningData,'processed_SOTtask2_power3/y_sim_linAcc.mat'),'y_sim_linAcc');
y_sim_linAcc_power4 = load(fullfile(bucket.pathToCovarianceTuningData,'processed_SOTtask2_power4/y_sim_linAcc.mat'),'y_sim_linAcc');

% Load y_sim_fext
y_sim_fext_power1 = load(fullfile(bucket.pathToCovarianceTuningData,'processed_SOTtask2_power1/y_sim_fext.mat'),'y_sim_fext');
y_sim_fext_power2 = load(fullfile(bucket.pathToCovarianceTuningData,'processed_SOTtask2_power2/y_sim_fext.mat'),'y_sim_fext');
y_sim_fext_power3 = load(fullfile(bucket.pathToCovarianceTuningData,'processed_SOTtask2_power3/y_sim_fext.mat'),'y_sim_fext');
y_sim_fext_power4 = load(fullfile(bucket.pathToCovarianceTuningData,'processed_SOTtask2_power4/y_sim_fext.mat'),'y_sim_fext');

% Load data
data_power3 = load(fullfile(bucket.pathToCovarianceTuningData,'processed_SOTtask2_power3/data.mat'),'data');

% Define new legend colors
meas_col   = [0.466666666666667   0.674509803921569   0.188235294117647];
power1_col = [1     0     1];
power2_col = [1     0     0];
power3_col = [0     0     1];
power4_col = [0     0     0];

%% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%                     MEASUREMENTS vs. ESTIMATIONS
%  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

if opts.totalVariableTuning
      % ------------------------ MEASUREMENTS -----------------------------
      total_variables_meas = [];
      % Filling with the linear acceleration
      for linAccIdx = 1  : nrOfLinAccelerometer
          total_variables_meas = [total_variables_meas; data_power3.data(blockIdx).data(linAccIdx).meas];
      end
      % Filling with the 6D wrenches
      for vectOrderIdx = 1 : length(dVectorOrder)
          for dataFextIdx = tmp.fextIndex(1) : tmp.fextIndex(end)      
              if strcmp(data_power3.data(blockIdx).data(dataFextIdx).id,dVectorOrder{vectOrderIdx})
                  total_variables_meas = [total_variables_meas; data_power3.data(blockIdx).data(dataFextIdx).meas];
                  break;
              end
          end
      end
      
      % ------------------------ NORM OF THE MEASUREMENTS -----------------
      for lenIdx = 1 : len
          totalnorm_meas(1,lenIdx) = norm(total_variables_meas(:,lenIdx));
      end
          
      % ------------------------ ESTIMATIONS ------------------------------
      total_variables_estim_power1 = [];
      total_variables_estim_power2 = [];
      total_variables_estim_power3 = [];
      total_variables_estim_power4 = [];
      % filling with the linear acceleration
      for linAccIdx = 1  : nrOfLinAccelerometer
          total_variables_estim_power1 = [total_variables_estim_power1; y_sim_linAcc_power1.y_sim_linAcc(blockIdx).meas{linAccIdx,1}];
          total_variables_estim_power2 = [total_variables_estim_power2; y_sim_linAcc_power2.y_sim_linAcc(blockIdx).meas{linAccIdx,1}];
          total_variables_estim_power3 = [total_variables_estim_power3; y_sim_linAcc_power3.y_sim_linAcc(blockIdx).meas{linAccIdx,1}];
          total_variables_estim_power4 = [total_variables_estim_power4; y_sim_linAcc_power4.y_sim_linAcc(blockIdx).meas{linAccIdx,1}];
      end
      % filling with the 6D wrenches
      for vectOrderIdx = 1 : length(dVectorOrder)
          total_variables_estim_power1 = [total_variables_estim_power1; y_sim_fext_power1.y_sim_fext.meas{vectOrderIdx,1}];
          total_variables_estim_power2 = [total_variables_estim_power2; y_sim_fext_power2.y_sim_fext.meas{vectOrderIdx,1}];
          total_variables_estim_power3 = [total_variables_estim_power3; y_sim_fext_power3.y_sim_fext.meas{vectOrderIdx,1}];
          total_variables_estim_power4 = [total_variables_estim_power4; y_sim_fext_power4.y_sim_fext.meas{vectOrderIdx,1}];
      end
      
      % ------------------------ DIFFERENCE -------------------------------
      total_variables_power1_diff = (total_variables_meas - total_variables_estim_power1);
      total_variables_power2_diff = (total_variables_meas - total_variables_estim_power2);
      total_variables_power3_diff = (total_variables_meas - total_variables_estim_power3);
      total_variables_power4_diff = (total_variables_meas - total_variables_estim_power4);
      
      % ------------------------ ABSOLUTE ERROR ---------------------------
      % ------------------------ |meas - estim| ---------------------------
      len = length(total_variables_power1_diff);
      for lenIdx = 1 : len
          absErr_power1(1,lenIdx) = norm(total_variables_power1_diff(:,lenIdx));
          absErr_power2(1,lenIdx) = norm(total_variables_power2_diff(:,lenIdx));
          absErr_power3(1,lenIdx) = norm(total_variables_power3_diff(:,lenIdx));
          absErr_power4(1,lenIdx) = norm(total_variables_power4_diff(:,lenIdx));
      end
      % plot
      for blockIdx = blockID
          fig = figure('Name', strcat('Absolute error - MEAS vs. ESTIM - Block ',num2str(blockIdx))','NumberTitle','off');
          axes1 = axes('Parent',fig,'FontSize',16);
          box(axes1,'on');
          hold(axes1,'on');
          
          plot_power1 = plot(absErr_power1,'color',power1_col,'lineWidth',4);
          hold on;
          plot_power2 = plot(absErr_power2,'color',power2_col,'lineWidth',4);
          hold on;
          plot_power3 = plot(absErr_power3,'color',power3_col,'lineWidth',4);
          hold on;
          plot_power4 = plot(absErr_power4,'color',power4_col,'lineWidth',4);
          grid on;
          title(sprintf('Absolute error, Block %d',blockIdx),'FontSize',20);
          ylabel('$\epsilon_{abs}$','Interpreter','latex');
          xlabel('samples');
          %           title(sprintf('%s',y_sim_linAcc_power3.y_sim_linAcc(blockIdx).order{linAccIdx, 1}),'FontSize',15 );
          leg = legend([plot_power1,plot_power2,plot_power3,plot_power4],{'estim n=1','estim n=2','estim n=3','estim n=4'});
          set(leg,'Interpreter','latex', ...
              'Position',[0.436917552718887 0.0353846154974763 0.158803168001834 0.0237869821356598], ...
              'Orientation','vertical');
          set(leg,'FontSize',30);
      end
      
      % ------------------------ RELATIVE ERROR ---------------------------
      % --------------------- |meas - estim|/|meas| -----------------------
      for lenIdx = 1 : len
          relErr_power1(1,lenIdx) = (absErr_power1(:,lenIdx)/totalnorm_meas(1,lenIdx));
          relErr_power2(1,lenIdx) = (absErr_power2(:,lenIdx)/totalnorm_meas(1,lenIdx));
          relErr_power3(1,lenIdx) = (absErr_power3(:,lenIdx)/totalnorm_meas(1,lenIdx));
          relErr_power4(1,lenIdx) = (absErr_power4(:,lenIdx)/totalnorm_meas(1,lenIdx));
      end
      % plot
      for blockIdx = blockID
          fig = figure('Name', strcat('Relative error - MEAS vs. ESTIM - Block ',num2str(blockIdx))','NumberTitle','off');
          axes1 = axes('Parent',fig,'FontSize',16);
          box(axes1,'on');
          hold(axes1,'on');
          
          plot_power1 = plot(relErr_power1,'color',power1_col,'lineWidth',4);
          hold on;
          plot_power2 = plot(relErr_power2,'color',power2_col,'lineWidth',4);
          hold on;
          plot_power3 = plot(relErr_power3,'color',power3_col,'lineWidth',4);
          hold on;
          plot_power4 = plot(relErr_power4,'color',power4_col,'lineWidth',4);
          grid on;
          title(sprintf('Relative error, Block %d',blockIdx),'FontSize',20);
          ylabel('$\epsilon_{rel}$','Interpreter','latex');
          xlabel('samples');
          %           title(sprintf('%s',y_sim_linAcc_power3.y_sim_linAcc(blockIdx).order{linAccIdx, 1}),'FontSize',15 );
          leg = legend([plot_power1,plot_power2,plot_power3,plot_power4],{'estim n=1','estim n=2','estim n=3','estim n=4'});
          set(leg,'Interpreter','latex', ...
              'Position',[0.436917552718887 0.0353846154974763 0.158803168001834 0.0237869821356598], ...
              'Orientation','vertical');
          set(leg,'FontSize',30);
      end
end
      
if opts.singleVariableTuning
    %%  Linear acceleration
    % ----x component
    nrOfLinAccelerometer = length(y_sim_linAcc_power3.y_sim_linAcc(1).order);
    for blockIdx = blockID
        fig = figure('Name', strcat('3D linear acceleration x component - MEAS vs. ESTIM - Block ',num2str(blockIdx))','NumberTitle','off');
        axes1 = axes('Parent',fig,'FontSize',16);
        box(axes1,'on');
        hold(axes1,'on');
        for linAccIdx = 1  : nrOfLinAccelerometer
            subplot (3,6,linAccIdx)
            % from the measurement
            plot1 = plot(data_power3.data(blockIdx).data(linAccIdx).meas(1,:),'color',meas_col,'lineWidth',0.8);
            hold on;
            % from the estimation (y_sim)
            plot_power1 = plot(y_sim_linAcc_power1.y_sim_linAcc(blockIdx).meas{linAccIdx,1}(1,:),'color',power1_col,'lineWidth',0.8);
            hold on;
            plot_power2 = plot(y_sim_linAcc_power2.y_sim_linAcc(blockIdx).meas{linAccIdx,1}(1,:),'color',power2_col,'lineWidth',0.8);
            hold on;
            plot_power3 = plot(y_sim_linAcc_power3.y_sim_linAcc(blockIdx).meas{linAccIdx,1}(1,:),'color',power3_col,'lineWidth',0.8);
            hold on;
            plot_power4 = plot(y_sim_linAcc_power4.y_sim_linAcc(blockIdx).meas{linAccIdx,1}(1,:),'color',power4_col,'lineWidth',0.8);
            grid on;
            title(sprintf('%s',y_sim_linAcc_power3.y_sim_linAcc(blockIdx).order{linAccIdx, 1}),'FontSize',15 );
            ylabel('$a^{lin}_{x}$ [m/$s^2$]','Interpreter','latex', 'FontSize',30 );
            %legend
            if linAccIdx == nrOfLinAccelerometer
                leg = legend([plot1,plot_power1,plot_power2,plot_power3,plot_power4],{'meas','estim n=1','estim n=2','estim n=3','estim n=4'});
                set(leg,'Interpreter','latex', ...
                    'Position',[0.436917552718887 0.0353846154974763 0.158803168001834 0.0237869821356598], ...
                    'Orientation','vertical');
                set(leg,'FontSize',30);
            end
        end
    end
    % ----y component
    for blockIdx = blockID
        fig = figure('Name', strcat('3D linear acceleration y component - MEAS vs. ESTIM - Block ',num2str(blockIdx))','NumberTitle','off');
        axes1 = axes('Parent',fig,'FontSize',16);
        box(axes1,'on');
        hold(axes1,'on');
        for linAccIdx = 1  : nrOfLinAccelerometer
            subplot (3,6,linAccIdx)
            % from the measurement
            plot1 = plot(data_power3.data(blockIdx).data(linAccIdx).meas(2,:),'color',meas_col,'lineWidth',1);
            hold on;
            % from the estimation (y_sim)
            plot_power1 = plot(y_sim_linAcc_power1.y_sim_linAcc(blockIdx).meas{linAccIdx,1}(2,:),'color',power1_col,'lineWidth',0.8);
            hold on;
            plot_power2 = plot(y_sim_linAcc_power2.y_sim_linAcc(blockIdx).meas{linAccIdx,1}(2,:),'color',power2_col,'lineWidth',0.8);
            hold on;
            plot_power3 = plot(y_sim_linAcc_power3.y_sim_linAcc(blockIdx).meas{linAccIdx,1}(2,:),'color',power3_col,'lineWidth',0.8);
            hold on;
            plot_power4 = plot(y_sim_linAcc_power4.y_sim_linAcc(blockIdx).meas{linAccIdx,1}(2,:),'color',power4_col,'lineWidth',0.8);
            grid on;
            title(sprintf('%s',y_sim_linAcc_power3.y_sim_linAcc(blockIdx).order{linAccIdx, 1}),'FontSize',15 );
            ylabel('$a^{lin}_{y}$ [m/$s^2$]','Interpreter','latex', 'FontSize',30 );
            %legend
            if linAccIdx == nrOfLinAccelerometer
                leg = legend([plot1,plot_power1,plot_power2,plot_power3,plot_power4],{'meas','estim n=1','estim n=2','estim n=3','estim n=4'});
                set(leg,'Interpreter','latex', ...
                    'Position',[0.436917552718887 0.0353846154974763 0.158803168001834 0.0237869821356598], ...
                    'Orientation','vertical');
                set(leg,'FontSize',30);
            end
        end
    end
    % ----z component
    for blockIdx = blockID
        fig = figure('Name', strcat('3D linear acceleration z component - MEAS vs. ESTIM - Block ',num2str(blockIdx))','NumberTitle','off');
        axes1 = axes('Parent',fig,'FontSize',16);
        box(axes1,'on');
        hold(axes1,'on');
        for linAccIdx = 1  : nrOfLinAccelerometer
            subplot (3,6,linAccIdx)
            % from the measurement
            plot1 = plot(data_power3.data(blockIdx).data(linAccIdx).meas(3,:),'color',meas_col,'lineWidth',1);
            hold on;
            % from the estimation (y_sim)
            plot_power1 = plot(y_sim_linAcc_power1.y_sim_linAcc(blockIdx).meas{linAccIdx,1}(3,:),'color',power1_col,'lineWidth',0.8);
            hold on;
            plot_power2 = plot(y_sim_linAcc_power2.y_sim_linAcc(blockIdx).meas{linAccIdx,1}(3,:),'color',power2_col,'lineWidth',0.8);
            hold on;
            plot_power3 = plot(y_sim_linAcc_power3.y_sim_linAcc(blockIdx).meas{linAccIdx,1}(3,:),'color',power3_col,'lineWidth',0.8);
            hold on;
            plot_power4 = plot(y_sim_linAcc_power4.y_sim_linAcc(blockIdx).meas{linAccIdx,1}(3,:),'color',power4_col,'lineWidth',0.8);
            grid on;
            title(sprintf('%s',y_sim_linAcc_power3.y_sim_linAcc(blockIdx).order{linAccIdx, 1}),'FontSize',15 );
            ylabel('$a^{lin}_{z}$ [m/$s^2$]','Interpreter','latex', 'FontSize',30 );
            %legend
            if linAccIdx == nrOfLinAccelerometer
                leg = legend([plot1,plot_power1,plot_power2,plot_power3,plot_power4],{'meas','estim n=1','estim n=2','estim n=3','estim n=4'});
                set(leg,'Interpreter','latex', ...
                    'Position',[0.436917552718887 0.0353846154974763 0.158803168001834 0.0237869821356598], ...
                    'Orientation','vertical');
                set(leg,'FontSize',30);
            end
        end
    end
    
    %%  3D external forces
    % Define range in data (only for block 1) for forces
    tmp.fextIndex = [];
    for fextInDataIdx = 1 : length(data(1).data)
        if data(1).data(fextInDataIdx).type == 1002
            tmp.fextIndex = [tmp.fextIndex; fextInDataIdx];
            continue;
        end
    end
    
    % ----x component
    for blockIdx = blockID
        fig = figure('Name', strcat('external force x component - MEAS vs. ESTIM - Block ',num2str(blockIdx))','NumberTitle','off');
        axes1 = axes('Parent',fig,'FontSize',16);
        box(axes1,'on');
        hold(axes1,'on');
        for vectOrderIdx = 1 : length(dVectorOrder)
            subplot (5,10,vectOrderIdx)
            % from the measurement
            for dataFextIdx = tmp.fextIndex(1) : tmp.fextIndex(end)
                if strcmp(data(blockIdx).data(dataFextIdx).id,dVectorOrder{vectOrderIdx})
                    plot1 = plot(data(blockIdx).data(dataFextIdx).meas(1,:),'color',meas_col,'lineWidth',2);
                    break;
                end
            end
            hold on
            % from the estimation (y_sim)
            plot_power1  = plot(y_sim_fext_power1.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(1,:),'color',power1_col,'lineWidth',0.8);
            hold on;
            plot_power2  = plot(y_sim_fext_power2.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(1,:),'color',power2_col,'lineWidth',0.8);
            hold on;
            plot_power3  = plot(y_sim_fext_power3.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(1,:),'color',power3_col,'lineWidth',0.8);
            hold on;
            plot_power4  = plot(y_sim_fext_power4.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(1,:),'color',power4_col,'lineWidth',0.8);
            grid on;
            title(sprintf('%s',dVectorOrder{vectOrderIdx,1}));
            ylabel('$f^{x}_{x}$ [N]','Interpreter','latex', 'FontSize',30 );
            %legend
            if vectOrderIdx == length(dVectorOrder)
                leg = legend([plot1,plot_power1,plot_power2,plot_power3,plot_power4],{'meas','estim n=1','estim n=2','estim n=3','estim n=4'});
                set(leg,'Interpreter','latex', ...
                    'Position',[0.436917552718887 0.0353846154974763 0.158803168001834 0.0237869821356598], ...
                    'Orientation','vertical');
                set(leg,'FontSize',30);
            end
        end
    end
    % ----y component
    for blockIdx = blockID
        fig = figure('Name', strcat('external force y component - MEAS vs. ESTIM - Block ',num2str(blockIdx))','NumberTitle','off');
        axes1 = axes('Parent',fig,'FontSize',16);
        box(axes1,'on');
        hold(axes1,'on');
        for vectOrderIdx = 1 : length(dVectorOrder)
            subplot (5,10,vectOrderIdx)
            % from the measurement
            for dataFextIdx = tmp.fextIndex(1) : tmp.fextIndex(end)
                if strcmp(data(blockIdx).data(dataFextIdx).id,dVectorOrder{vectOrderIdx})
                    plot1 = plot(data(blockIdx).data(dataFextIdx).meas(2,:),'color',meas_col,'lineWidth',2);
                    break;
                end
            end
            hold on
            % from the estimation (y_sim)
            plot_power1  = plot(y_sim_fext_power1.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(2,:),'color',power1_col,'lineWidth',0.8);
            hold on;
            plot_power2  = plot(y_sim_fext_power2.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(2,:),'color',power2_col,'lineWidth',0.8);
            hold on;
            plot_power3  = plot(y_sim_fext_power3.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(2,:),'color',power3_col,'lineWidth',0.8);
            hold on;
            plot_power4  = plot(y_sim_fext_power4.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(2,:),'color',power4_col,'lineWidth',0.8);
            grid on;
            title(sprintf('%s',dVectorOrder{vectOrderIdx,1}));
            ylabel('$f^{x}_{y}$ [N]','Interpreter','latex', 'FontSize',30 );
            %legend
            if vectOrderIdx == length(dVectorOrder)
                leg = legend([plot1,plot_power1,plot_power2,plot_power3,plot_power4],{'meas','estim n=1','estim n=2','estim n=3','estim n=4'});
                set(leg,'Interpreter','latex', ...
                    'Position',[0.436917552718887 0.0353846154974763 0.158803168001834 0.0237869821356598], ...
                    'Orientation','vertical');
                set(leg,'FontSize',30);
            end
        end
    end
    % ----z component
    for blockIdx = blockID
        fig = figure('Name', strcat('external force z component - MEAS vs. ESTIM - Block ',num2str(blockIdx))','NumberTitle','off');
        axes1 = axes('Parent',fig,'FontSize',16);
        box(axes1,'on');
        hold(axes1,'on');
        for vectOrderIdx = 1 : length(dVectorOrder)
            subplot (5,10,vectOrderIdx)
            % from the measurement
            for dataFextIdx = tmp.fextIndex(1) : tmp.fextIndex(end)
                if strcmp(data(blockIdx).data(dataFextIdx).id,dVectorOrder{vectOrderIdx})
                    plot1 = plot(data(blockIdx).data(dataFextIdx).meas(3,:),'color',meas_col,'lineWidth',2);
                    break;
                end
            end
            hold on
            % from the estimation (y_sim)
            plot_power1  = plot(y_sim_fext_power1.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(3,:),'color',power1_col,'lineWidth',0.8);
            hold on;
            plot_power2  = plot(y_sim_fext_power2.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(3,:),'color',power2_col,'lineWidth',0.8);
            hold on;
            plot_power3  = plot(y_sim_fext_power3.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(3,:),'color',power3_col,'lineWidth',0.8);
            hold on;
            plot_power4  = plot(y_sim_fext_power4.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(3,:),'color',power4_col,'lineWidth',0.8);
            grid on;
            title(sprintf('%s',dVectorOrder{vectOrderIdx,1}));
            ylabel('$f^{x}_{z}$ [N]','Interpreter','latex', 'FontSize',30 );
            %legend
            if vectOrderIdx == length(dVectorOrder)
                leg = legend([plot1,plot_power1,plot_power2,plot_power3,plot_power4],{'meas','estim n=1','estim n=2','estim n=3','estim n=4'});
                set(leg,'Interpreter','latex', ...
                    'Position',[0.436917552718887 0.0353846154974763 0.158803168001834 0.0237869821356598], ...
                    'Orientation','vertical');
                set(leg,'FontSize',30);
            end
        end
    end
    
    %%  3D external moments
    % ----x component
    for blockIdx = blockID
        fig = figure('Name', strcat('external moment x component - MEAS vs. ESTIM - Block ',num2str(blockIdx))','NumberTitle','off');
        axes1 = axes('Parent',fig,'FontSize',16);
        box(axes1,'on');
        hold(axes1,'on');
        for vectOrderIdx = 1 : length(dVectorOrder)
            subplot (5,10,vectOrderIdx)
            % from the measurement
            for dataFextIdx = tmp.fextIndex(1) : tmp.fextIndex(end)
                if strcmp(data(blockIdx).data(dataFextIdx).id,dVectorOrder{vectOrderIdx})
                    plot1 = plot(data(blockIdx).data(dataFextIdx).meas(4,:),'color',meas_col,'lineWidth',2);
                    break;
                end
            end
            hold on
            % from the estimation (y_sim)
            plot_power1 = plot(y_sim_fext_power1.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(4,:),'color',power1_col,'lineWidth',0.8);
            hold on;
            plot_power2 = plot(y_sim_fext_power2.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(4,:),'color',power2_col,'lineWidth',0.8);
            hold on;
            plot_power3 = plot(y_sim_fext_power3.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(4,:),'color',power3_col,'lineWidth',0.8);
            hold on;
            plot_power4 = plot(y_sim_fext_power4.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(4,:),'color',power4_col,'lineWidth',0.8);
            grid on;
            title(sprintf('%s',dVectorOrder{vectOrderIdx,1}));
            ylabel('$m^{x}_{x}$ [Nm]','Interpreter','latex', 'FontSize',30 );
            %legend
            if vectOrderIdx == length(dVectorOrder)
                leg = legend([plot1,plot_power1,plot_power2,plot_power3,plot_power4],{'meas','estim n=1','estim n=2','estim n=3','estim n=4'});
                set(leg,'Interpreter','latex', ...
                    'Position',[0.436917552718887 0.0353846154974763 0.158803168001834 0.0237869821356598], ...
                    'Orientation','vertical');
                set(leg,'FontSize',30);
            end
        end
    end
    % ----y component
    for blockIdx = blockID
        fig = figure('Name', strcat('external moment y component - MEAS vs. ESTIM - Block ',num2str(blockIdx))','NumberTitle','off');
        axes1 = axes('Parent',fig,'FontSize',16);
        box(axes1,'on');
        hold(axes1,'on');
        for vectOrderIdx = 1 : length(dVectorOrder)
            subplot (5,10,vectOrderIdx)
            % from the measurement
            for dataFextIdx = tmp.fextIndex(1) : tmp.fextIndex(end)
                if strcmp(data(blockIdx).data(dataFextIdx).id,dVectorOrder{vectOrderIdx})
                    plot1 = plot(data(blockIdx).data(dataFextIdx).meas(5,:),'color',meas_col,'lineWidth',2);
                    break;
                end
            end
            hold on
            % from the estimation (y_sim)
            plot_power1 = plot(y_sim_fext_power1.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(5,:),'color',power1_col,'lineWidth',0.8);
            hold on;
            plot_power2 = plot(y_sim_fext_power2.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(5,:),'color',power2_col,'lineWidth',0.8);
            hold on;
            plot_power3 = plot(y_sim_fext_power3.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(5,:),'color',power3_col,'lineWidth',0.8);
            hold on;
            plot_power4 = plot(y_sim_fext_power4.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(5,:),'color',power4_col,'lineWidth',0.8);
            grid on;
            title(sprintf('%s',dVectorOrder{vectOrderIdx,1}));
            ylabel('$m^{x}_{y}$ [Nm]','Interpreter','latex', 'FontSize',30 );
            %legend
            if vectOrderIdx == length(dVectorOrder)
                leg = legend([plot1,plot_power1,plot_power2,plot_power3,plot_power4],{'meas','estim n=1','estim n=2','estim n=3','estim n=4'});
                set(leg,'Interpreter','latex', ...
                    'Position',[0.436917552718887 0.0353846154974763 0.158803168001834 0.0237869821356598], ...
                    'Orientation','vertical');
                set(leg,'FontSize',30);
            end
        end
    end
    % ----z component
    for blockIdx = blockID
        fig = figure('Name', strcat('external moment z component - MEAS vs. ESTIM - Block ',num2str(blockIdx))','NumberTitle','off');
        axes1 = axes('Parent',fig,'FontSize',16);
        box(axes1,'on');
        hold(axes1,'on');
        for vectOrderIdx = 1 : length(dVectorOrder)
            subplot (5,10,vectOrderIdx)
            % from the measurement
            for dataFextIdx = tmp.fextIndex(1) : tmp.fextIndex(end)
                if strcmp(data(blockIdx).data(dataFextIdx).id,dVectorOrder{vectOrderIdx})
                    plot1 = plot(data(blockIdx).data(dataFextIdx).meas(6,:),'color',meas_col,'lineWidth',2);
                    break;
                end
            end
            hold on
            % from the estimation (y_sim)
            plot_power1 = plot(y_sim_fext_power1.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(6,:),'color',power1_col,'lineWidth',0.8);
            hold on;
            plot_power2 = plot(y_sim_fext_power2.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(6,:),'color',power2_col,'lineWidth',0.8);
            hold on;
            plot_power3 = plot(y_sim_fext_power3.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(6,:),'color',power3_col,'lineWidth',0.8);
            hold on;
            plot_power4 = plot(y_sim_fext_power4.y_sim_fext(blockIdx).meas{vectOrderIdx,1}(6,:),'color',power4_col,'lineWidth',0.8);
            grid on;
            title(sprintf('%s',dVectorOrder{vectOrderIdx,1}));
            ylabel('$m^{x}_{z}$ [Nm]','Interpreter','latex', 'FontSize',30 );
            %legend
            if vectOrderIdx == length(dVectorOrder)
                leg = legend([plot1,plot_power1,plot_power2,plot_power3,plot_power4],{'meas','estim n=1','estim n=2','estim n=3','estim n=4'});
                set(leg,'Interpreter','latex', ...
                    'Position',[0.436917552718887 0.0353846154974763 0.158803168001834 0.0237869821356598], ...
                    'Orientation','vertical');
                set(leg,'FontSize',30);
            end
        end
    end
end
