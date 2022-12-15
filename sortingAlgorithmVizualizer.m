classdef sortingAlgorithmVizualizer < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        LeftPanel                      matlab.ui.container.Panel
        SeadseButton                   matlab.ui.control.Button
        ZamchejButton_2                matlab.ui.control.Button
        DobaeknsEditField              matlab.ui.control.NumericEditField
        DobaeknsEditFieldLabel         matlab.ui.control.Label
        KoncovhodnotaEditField         matlab.ui.control.NumericEditField
        KoncovhodnotaEditFieldLabel    matlab.ui.control.Label
        KrokEditField                  matlab.ui.control.NumericEditField
        KrokEditFieldLabel             matlab.ui.control.Label
        PotenhodnotaEditField          matlab.ui.control.NumericEditField
        PotenhodnotaEditFieldLabel     matlab.ui.control.Label
        GenerovnselLabel               matlab.ui.control.Label
        VybertealgoritmusListBox       matlab.ui.control.ListBox
        VybertealgoritmusListBoxLabel  matlab.ui.control.Label
        AlgoritmickporovnvaLabel       matlab.ui.control.Label
        RightPanel                     matlab.ui.container.Panel
        GridLayout3                    matlab.ui.container.GridLayout
        MenPanel                       matlab.ui.container.Panel
        GridLayout4                    matlab.ui.container.GridLayout
        OdvozenaSlozitostValue         matlab.ui.control.Label
        PocetKroku                     matlab.ui.control.Label
        OdvozensloitostLabel           matlab.ui.control.Label
        PoetkrokLabel                  matlab.ui.control.Label
        AsymtoticksloitostPanel        matlab.ui.container.Panel
        GridLayout2                    matlab.ui.container.GridLayout
        NejlepsiSlozitostValue         matlab.ui.control.Label
        NejlepLabel                    matlab.ui.control.Label
        PrumernaSlozitostValue         matlab.ui.control.Label
        PrmrnLabel                     matlab.ui.control.Label
        NejhorsiSlozitostValue         matlab.ui.control.Label
        NejhorLabel                    matlab.ui.control.Label
        MainChart                      matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = private)
        COLOR_BLUE = [0 0.4470 0.7410];
        COLOR_PURPLE = [0.4940 0.1840 0.5560];
        COLOR_ORANGE = [0.8500 0.3250 0.0980];
        COLOR_YELLOW = [0.9290 0.6940 0.1250];
        COLOR_RED = [0.6350 0.0780 0.1840];
        COLOR_GREEN = [0.4660 0.6740 0.1880];
        running = false;
        algorithmType
        minSortingValue
        maxSortingValue
        stepValue
        moveTime
        X
        labels
        barChart
        stopApp = false;
        steps = 0;
    end
    
    methods (Access = private)
        function setSteps(app,x)
            app.steps = x;
            app.PocetKroku.Text = num2str(app.steps);
        end
        function calcAndPrintComplexity(app)
            if app.algorithmType == "Counting sort"
                app.PocetKroku.Text = num2str(length(app.X)+abs(app.maxSortingValue-app.minSortingValue));
                app.OdvozenaSlozitostValue.Text = "$\mathcal{0}(n+k)$";
                drawnow;
                return
            end

            logaritmic = log2(length(app.X));
            linear = length(app.X);
            linearitmetic = length(app.X)*log2(length(app.X));
            quadratic = length(app.X)^2;
            cubic = length(app.X)^3;
            
            print = "Chyba ve výpočtu.";
            if (app.steps <= logaritmic*1.1)
                print = "$\mathcal{O}(n)$";
            elseif (app.steps > logaritmic*1.1 && app.steps <= linear*0.8)
                print = "$\mathcal{O}(\log n)$";
            elseif (app.steps > linear*0.8 && app.steps <= linearitmetic*0.8)
                print = "$\mathcal{O}(n)$";
            elseif (app.steps > linearitmetic*0.8 && app.steps <= quadratic*0.8)
                print = "$\mathcal{O}(n \log n)$";
            elseif (app.steps > quadratic*0.8 && app.steps<= cubic*0.8)
                print = "$\mathcal{O}(n^2)$";
            else
                print = "$> \mathcal{O}(n^2)$";
            end
            app.OdvozenaSlozitostValue.Text = print;
            drawnow;
        end
        function enableRunning(app)
            app.running = true;
            app.ZamchejButton_2.Enable = 'off';
            app.KrokEditField.Enable = 'off';
            app.DobaeknsEditField.Enable = 'off';
            app.KoncovhodnotaEditField.Enable = 'off';
            app.VybertealgoritmusListBox.Enable = 'off';
            app.PotenhodnotaEditField.Enable = 'off';
            app.SeadseButton.Text = 'STOP';
            app.SeadseButton.BackgroundColor = [0.85,0.33,0.10];
            drawnow;
        end
        function disableRunning(app)
            app.running = false;
            app.stopApp = false;
            app.ZamchejButton_2.Enable = 'on';
            app.KrokEditField.Enable = 'on';
            app.DobaeknsEditField.Enable = 'on';
            app.KoncovhodnotaEditField.Enable = 'on';
            app.VybertealgoritmusListBox.Enable = 'on';
            app.PotenhodnotaEditField.Enable = 'on';
            app.SeadseButton.Enable = 'on';
            app.SeadseButton.Text = 'Seřad se!';
            app.SeadseButton.BackgroundColor = [0.80,0.80,0.80];
            drawnow;
        end
        function [from, to, names] = tree_construct(~,X)
            from = zeros(1,length(X)-1);
            to = zeros(1,length(X)-1);
            names{length(X)-1} = {};
            index = 1;
            for i=1:length(X)
                for j=1:2
                    if index >= length(X)
                        continue;
                    end
                    from(index) = i;
                    to(index) = i*2+j-1;
                    index = index+1;
                end
                names{i} = num2str(X(i));
            end
        end
        % shuffle, is_sorted
        function X = shuffle(~,X)
            X = X(randperm(length(X)));
        end
        function R = is_sorted(app,X)
            for i = 1:length(X)-1
                %setSteps(app,app.steps+1);
                app.barChart.CData(i,:) = app.COLOR_YELLOW;
                pause(app.moveTime/10);
                drawnow;
                if X(i+1) > X(i)
                    R = false;
                    app.barChart.CData(i+1,:) = app.COLOR_RED;
                    pause(app.moveTime/2);
                    drawnow;
                    for j=1:length(X)
                        app.barChart.CData(j,:) = app.COLOR_BLUE;
                    end
                    drawnow;
                    return
                end
                app.barChart.CData(i,:) = app.COLOR_GREEN;
                drawnow;
            end
            app.barChart.CData(length(X),:) = app.COLOR_GREEN;
            drawnow;
            pause(app.moveTime/2);
            R = true;
        end
        function R = is_sorted_heap(app,X)
            for i=1:length(X)-1
                setSteps(app,app.steps+1);
                highlight(app.barChart,i, "NodeColor", app.COLOR_YELLOW);
                pause(app.moveTime/10);
                if X(i+1) > X(i)
                    R = false;
                    highlight(app.barChart,i, "NodeColor", app.COLOR_RED);
                    drawnow;
                    pause(app.moveTime/2);
                    return
                end
                highlight(app.barChart,i, "NodeColor", app.COLOR_GREEN);
                drawnow;
            end
            highlight(app.barChart,length(X), "NodeColor", app.COLOR_GREEN);
            pause(app.moveTime/2);
            R = true;
        end
        % Sorting algs
        function X = heap_sort(app,X)
            [from, to, names] = tree_construct(app,X);
            app.barChart = plot(app.MainChart,graph(from,to,[],names));
            drawnow;
            for i=ceil(length(X)/2):-1:1
                if app.stopApp
                    return;
                end

                pause(app.moveTime);
                X = heapify(app,X,length(X),i);
                [from, to, names] = tree_construct(app,X);
                app.barChart = plot(app.MainChart,graph(from,to,[],names));
                drawnow;
            end
            pause(app.moveTime);
            for i=length(X):-1:1
                if app.stopApp
                    return;
                end
                highlight(app.barChart,[1, i], "NodeColor", "r");
                [X(1), X(i)] = deal(X(i), X(1));
                pause(app.moveTime);
                [from, to, names] = tree_construct(app,X);
                app.barChart = plot(app.MainChart,graph(from,to,[],names));
                drawnow;
                pause(app.moveTime);
                X = heapify(app,X,i,1);
                [from, to, names] = tree_construct(app,X);
                app.barChart = plot(app.MainChart,graph(from,to,[],names));
                drawnow;
            end
            [from, to, names] = tree_construct(app,X);
            app.barChart = plot(app.MainChart,graph(from,to,[],names));
            drawnow;
            if is_sorted_heap(app,X)
                app.X = X;
            end
            
        end
        function X = heapify(app,X,n,i)
            if app.stopApp
                return;
            end
            setSteps(app,app.steps+1);
            smallest = i;
            left = 2*i;
            right = 2*i+1;
            if left < n && X(smallest) > X(left)
                smallest = left;
            end
            if right < n && X(smallest) > X(right)
                smallest = right;
            end
            if smallest ~= i
                [X(smallest), X(i)] = deal(X(i),X(smallest));
                highlight(app.barChart,[smallest, i], "NodeColor", app.COLOR_RED);
                pause(app.moveTime);
                [from, to, names] = tree_construct(app,X);
                app.barChart = plot(app.MainChart,graph(from,to,[],names));
                drawnow;
                X = heapify(app,X,n,smallest);
                pause(app.moveTime);
            end
        end
        function X = bubble_sort(app,X)
            sorted = [];
            for i=1:length(X)
                for j=1:length(X)-i
                    setSteps(app,app.steps+1);
                    if app.stopApp
                        return;
                    end
                    app.barChart.CData(j,:) = app.COLOR_YELLOW;
                    pause(app.moveTime/2);
                    drawnow;
                    app.barChart.CData(j+1,:) = app.COLOR_ORANGE;
                    drawnow;
                    pause(app.moveTime/2);
                    if X(j) < X(j+1)
                        setSteps(app,app.steps+1);
                        [X(j), X(j+1)] = deal(X(j+1), X(j));
                        app.barChart = bar(app.MainChart,X,'FaceColor','flat');
                        app.barChart.CData(j+1,:) = app.COLOR_YELLOW;
                        app.barChart.CData(j,:) = app.COLOR_ORANGE;
                        for k=1:length(sorted)
                            app.barChart.CData(sorted(k),:) = app.COLOR_GREEN;
                        end
                        drawnow;
                        pause(app.moveTime/2);
                    end
                    app.barChart.CData(j,:) = app.COLOR_BLUE;
                    for k=1:length(sorted)
                        app.barChart.CData(sorted(k),:) = app.COLOR_GREEN;
                    end
                    drawnow;
                end
                sorted(end+1) = length(X)-i+1;
                for k=1:length(sorted)
                    app.barChart.CData(sorted(k),:) = app.COLOR_GREEN;
                end
                drawnow;
            end
            if is_sorted(app,X)
                app.X = X;
            end
        end
        function X = counting_sort(app,X)
            
            % If there is some double -> multiplication to integer
            multipl = 0;
            while ~all(mod(X,1) == 0)
                X = X*10;
                multipl = multipl+1;
            end
            move = 0;
            if min(X) < 0
                move = abs(min(X));
                X = X + move;
            end
        
            app.barChart = bar(app.MainChart,X,'FaceColor','flat');
            % Algorithm
            to_find = min(X):max(X);
            occurencies = hist(X,to_find);
            pause(app.moveTime);
            app.barChart = bar(app.MainChart,to_find,'FaceColor','flat');
            ylabel(app.MainChart,"Hledané hodnoty")
            pause(app.moveTime*2);
            app.barChart = bar(app.MainChart,occurencies,'FaceColor','flat');
            ylabel(app.MainChart,"Cetnost čísel")
            pause(app.moveTime*2);
            ylabel(app.MainChart,"Hodnoty")
        
            index = 1;
            for i=length(occurencies):-1:1
                while (occurencies(i) ~= 0)
                    X(index) = to_find(i);
                    app.barChart = bar(app.MainChart,X,'FaceColor','flat');
                    app.barChart.CData(index,:) = app.COLOR_YELLOW;
                    pause(app.moveTime/2);
                    occurencies(i) = occurencies(i)-1;
                    index = index+1;
                end
            end
            app.barChart = bar(app.MainChart,X,'FaceColor','flat');
        
            % Back to reality
            X = X-move;
            if multipl ~= 0
                X = X/(multipl*10);
            end
            if is_sorted(app,X)
                app.X = X;
            end
        end
        function X = bogo_sort(app,X)
            while ~is_sorted(app,X)
                if app.stopApp
                    return;
                end
                X = shuffle(app,X);
                setSteps(app,app.steps+1);
                app.barChart = bar(app.MainChart,X,'FaceColor','flat');
            end
        end
        function X = insertion_sort(app,X)
            for i = 1:length(X)-1
                setSteps(app,app.steps+1);
                if app.stopApp
                    return;
                end
                if i > 1
                    app.barChart.CData(i-1,:) = app.COLOR_BLUE;
                end
                app.barChart.CData(i,:) = app.COLOR_YELLOW;
                drawnow;
                pause(app.moveTime/2);
                j = i+1;
                tmp = X(j);
                app.barChart.CData(j,:) = app.COLOR_YELLOW;
                while j > 1 && tmp > X(j-1)
                    setSteps(app,app.steps+1);
                    if app.stopApp
                        return;
                    end
                    if j ~= i+1
                        app.barChart.CData(j,:) = app.COLOR_BLUE;
                    end
                    if j > 2
                        app.barChart.CData(j-1,:) = app.COLOR_ORANGE;
                    end
                    drawnow;
                    pause(app.moveTime/2);
                    X(j) = X(j-1);
                    j = j-1;
                end
                X(j) = tmp;
                app.barChart = bar(app.MainChart,X,'FaceColor','flat');
                app.barChart.CData(i,:) = app.COLOR_YELLOW;
                drawnow;
                pause(app.moveTime);
            end
            app.barChart = bar(app.MainChart,X,'FaceColor','flat');
            if is_sorted(app,X)
                app.X = X;
            end
            setSteps(app,app.steps+1);
            drawnow;
        end
        function X = selection_sort(app,X)
            for i = 1:length(X)-1
                maxIndex = i;
                for j = i+1:length(X)
                    setSteps(app,app.steps+1);
                    if app.stopApp
                        return;
                    end
                    app.barChart.CData(j,:) = app.COLOR_YELLOW;
                    if j > i+1 && j-1 ~= maxIndex
                        app.barChart.CData(j-1,:) = app.COLOR_BLUE;
                    end
                    pause(app.moveTime/2);
                    drawnow;

                    if X(j) > X(maxIndex)
                        setSteps(app,app.steps+1);
                        app.barChart.CData(maxIndex,:) = app.COLOR_BLUE;
                        maxIndex = j;
                        app.barChart.CData(maxIndex,:) = app.COLOR_ORANGE;
                        drawnow;
                    end
                end
                app.barChart.CData(i,:) = app.COLOR_RED;
                app.barChart.CData(maxIndex,:) = app.COLOR_RED;
                pause(app.moveTime);
                drawnow;
                tmp = X(i);
                X(i) = X(maxIndex);
                X(maxIndex) = tmp;
                app.barChart = bar(app.MainChart,X,'FaceColor','flat');
                drawnow;
            end
            setSteps(app,app.steps+1);
            drawnow;
            if is_sorted(app,X)
                app.X = X;
            end
        end

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.VybertealgoritmusListBox.Value = "Bubble sort";
            NatidatazformuleButtonPushed(app);
            app.X = app.maxSortingValue:(-1)*app.stepValue:app.minSortingValue;
            app.barChart = bar(app.MainChart,app.X,'FaceColor','flat');
            app.stopApp = false;
        end

        % Button pushed function: SeadseButton
        function SeadseButtonPushed(app, event)
            if app.running
                app.stopApp = true;
                return;
            end
            % Print values in bar
            app.barChart = bar(app.MainChart,app.X,'FaceColor','flat');

            app.enableRunning();
            app.steps = 0;
            app.PocetKroku.Text = num2str(app.steps);
            app.OdvozenaSlozitostValue.Text = "";
            switch app.algorithmType
                case "Bubble sort"
                    app.X = bubble_sort(app,app.X);
                case "Bogo sort"
                    app.X = bogo_sort(app,app.X);
                case "Insertion sort"
                    app.X = insertion_sort(app,app.X);
                case "Selection sort"
                    app.X = selection_sort(app,app.X);
                case "Heap sort"
                    app.X = heap_sort(app,app.X);
                case "Counting sort"
                    app.X = counting_sort(app,app.X);
            end
            calcAndPrintComplexity(app);
            app.disableRunning();
        end

        % Value changed function: DobaeknsEditField, 
        % ...and 4 other components
        function NatidatazformuleButtonPushed(app, event)
            app.algorithmType = app.VybertealgoritmusListBox.Value;
            switch app.algorithmType
                case "Bubble sort"
                    app.NejhorsiSlozitostValue.Text = "$\mathcal{O}(n^2)$";
                    app.PrumernaSlozitostValue.Text = "$\Theta(n^2)$";
                    app.NejlepsiSlozitostValue.Text = "$\Omega(n^2)$";
                case "Bogo sort"
                    app.NejhorsiSlozitostValue.Text = "$\mathcal{O}(\infty)$";
                    app.PrumernaSlozitostValue.Text = "$\Theta(n!)$";
                    app.NejlepsiSlozitostValue.Text = "$\Omega(n)$";
                case "Insertion sort"
                    app.NejhorsiSlozitostValue.Text = "$\mathcal{O}(n^2)$";
                    app.PrumernaSlozitostValue.Text = "$\Theta(n^2)$";
                    app.NejlepsiSlozitostValue.Text = "$\Omega(n)$";
                case "Selection sort"
                    app.NejhorsiSlozitostValue.Text = "$\mathcal{O}(n^2)$";
                    app.PrumernaSlozitostValue.Text = "$\Theta(n^2)$";
                    app.NejlepsiSlozitostValue.Text = "$\Omega(n^2)$";
                case "Heap sort"
                    app.NejhorsiSlozitostValue.Text = "$\mathcal{O}(n\log n)$";
                    app.PrumernaSlozitostValue.Text = "$\Theta(n\log n)$";
                    app.NejlepsiSlozitostValue.Text = "$\Omega(n\log n)$";
                case "Counting sort"
                    app.NejhorsiSlozitostValue.Text = "$\mathcal{O}(n+k)$";
                    app.PrumernaSlozitostValue.Text = "$\Theta(n+k)$";
                    app.NejlepsiSlozitostValue.Text = "$\Omega(n+k)$";
            end

            app.minSortingValue = app.PotenhodnotaEditField.Value;
            app.maxSortingValue = app.KoncovhodnotaEditField.Value;
            app.stepValue = app.KrokEditField.Value;
            app.moveTime = app.DobaeknsEditField.Value;
            app.X = app.maxSortingValue:(-1)*app.stepValue:app.minSortingValue;
            app.barChart = bar(app.MainChart,app.X,'FaceColor','flat');
        end

        % Button pushed function: ZamchejButton_2
        function ZamchejButton_2Pushed(app, event)
            NatidatazformuleButtonPushed(app);
            app.X = shuffle(app,app.X);
            app.barChart = bar(app.MainChart,app.X);
            app.barChart.FaceColor = "flat";
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {480, 480};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {220, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {220, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.BackgroundColor = [0.902 0.902 0.902];
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create AlgoritmickporovnvaLabel
            app.AlgoritmickporovnvaLabel = uilabel(app.LeftPanel);
            app.AlgoritmickporovnvaLabel.HorizontalAlignment = 'center';
            app.AlgoritmickporovnvaLabel.FontSize = 14;
            app.AlgoritmickporovnvaLabel.FontWeight = 'bold';
            app.AlgoritmickporovnvaLabel.Position = [25 435 172 22];
            app.AlgoritmickporovnvaLabel.Text = 'Algoritmický porovnávač';

            % Create VybertealgoritmusListBoxLabel
            app.VybertealgoritmusListBoxLabel = uilabel(app.LeftPanel);
            app.VybertealgoritmusListBoxLabel.WordWrap = 'on';
            app.VybertealgoritmusListBoxLabel.Position = [26 357 62 58];
            app.VybertealgoritmusListBoxLabel.Text = 'Vyberte algoritmus';

            % Create VybertealgoritmusListBox
            app.VybertealgoritmusListBox = uilistbox(app.LeftPanel);
            app.VybertealgoritmusListBox.Items = {'Bubble sort', 'Selection sort', 'Insertion sort', 'Heap sort', 'Counting sort', 'Bogo sort'};
            app.VybertealgoritmusListBox.ValueChangedFcn = createCallbackFcn(app, @NatidatazformuleButtonPushed, true);
            app.VybertealgoritmusListBox.Position = [89 343 109 74];
            app.VybertealgoritmusListBox.Value = {};

            % Create GenerovnselLabel
            app.GenerovnselLabel = uilabel(app.LeftPanel);
            app.GenerovnselLabel.BackgroundColor = [0.8 0.8 0.8];
            app.GenerovnselLabel.HorizontalAlignment = 'center';
            app.GenerovnselLabel.FontWeight = 'bold';
            app.GenerovnselLabel.FontColor = [0.149 0.149 0.149];
            app.GenerovnselLabel.Position = [21 301 180 22];
            app.GenerovnselLabel.Text = 'Generování čísel';

            % Create PotenhodnotaEditFieldLabel
            app.PotenhodnotaEditFieldLabel = uilabel(app.LeftPanel);
            app.PotenhodnotaEditFieldLabel.WordWrap = 'on';
            app.PotenhodnotaEditFieldLabel.Tooltip = {'Zvolte počáteční hodnotu řazených čísel'};
            app.PotenhodnotaEditFieldLabel.Position = [21 259 62 30];
            app.PotenhodnotaEditFieldLabel.Text = 'Počáteční hodnota';

            % Create PotenhodnotaEditField
            app.PotenhodnotaEditField = uieditfield(app.LeftPanel, 'numeric');
            app.PotenhodnotaEditField.Limits = [-1000 1000];
            app.PotenhodnotaEditField.RoundFractionalValues = 'on';
            app.PotenhodnotaEditField.ValueDisplayFormat = '%.2f';
            app.PotenhodnotaEditField.ValueChangedFcn = createCallbackFcn(app, @NatidatazformuleButtonPushed, true);
            app.PotenhodnotaEditField.HorizontalAlignment = 'center';
            app.PotenhodnotaEditField.Position = [91 256 110 33];
            app.PotenhodnotaEditField.Value = 1;

            % Create KrokEditFieldLabel
            app.KrokEditFieldLabel = uilabel(app.LeftPanel);
            app.KrokEditFieldLabel.WordWrap = 'on';
            app.KrokEditFieldLabel.Tooltip = {'Zvolte počáteční hodnotu řazených čísel'};
            app.KrokEditFieldLabel.Position = [21 223 62 22];
            app.KrokEditFieldLabel.Text = 'Krok';

            % Create KrokEditField
            app.KrokEditField = uieditfield(app.LeftPanel, 'numeric');
            app.KrokEditField.Limits = [-1000 1000];
            app.KrokEditField.RoundFractionalValues = 'on';
            app.KrokEditField.ValueDisplayFormat = '%.2f';
            app.KrokEditField.ValueChangedFcn = createCallbackFcn(app, @NatidatazformuleButtonPushed, true);
            app.KrokEditField.HorizontalAlignment = 'center';
            app.KrokEditField.Position = [91 219 110 30];
            app.KrokEditField.Value = 1;

            % Create KoncovhodnotaEditFieldLabel
            app.KoncovhodnotaEditFieldLabel = uilabel(app.LeftPanel);
            app.KoncovhodnotaEditFieldLabel.WordWrap = 'on';
            app.KoncovhodnotaEditFieldLabel.Tooltip = {'Zvolte počáteční hodnotu řazených čísel'};
            app.KoncovhodnotaEditFieldLabel.Position = [21 179 62 30];
            app.KoncovhodnotaEditFieldLabel.Text = 'Koncová hodnota';

            % Create KoncovhodnotaEditField
            app.KoncovhodnotaEditField = uieditfield(app.LeftPanel, 'numeric');
            app.KoncovhodnotaEditField.Limits = [-1000 1000];
            app.KoncovhodnotaEditField.ValueDisplayFormat = '%.2f';
            app.KoncovhodnotaEditField.ValueChangedFcn = createCallbackFcn(app, @NatidatazformuleButtonPushed, true);
            app.KoncovhodnotaEditField.HorizontalAlignment = 'center';
            app.KoncovhodnotaEditField.Position = [91 179 110 30];
            app.KoncovhodnotaEditField.Value = 20;

            % Create DobaeknsEditFieldLabel
            app.DobaeknsEditFieldLabel = uilabel(app.LeftPanel);
            app.DobaeknsEditFieldLabel.WordWrap = 'on';
            app.DobaeknsEditFieldLabel.Tooltip = {'Zvolte počáteční hodnotu řazených čísel'};
            app.DobaeknsEditFieldLabel.Position = [22 139 62 30];
            app.DobaeknsEditFieldLabel.Text = 'Doba čekání [s]';

            % Create DobaeknsEditField
            app.DobaeknsEditField = uieditfield(app.LeftPanel, 'numeric');
            app.DobaeknsEditField.Limits = [0.0001 5];
            app.DobaeknsEditField.ValueDisplayFormat = '%.3f';
            app.DobaeknsEditField.ValueChangedFcn = createCallbackFcn(app, @NatidatazformuleButtonPushed, true);
            app.DobaeknsEditField.HorizontalAlignment = 'center';
            app.DobaeknsEditField.Position = [91 139 110 30];
            app.DobaeknsEditField.Value = 0.5;

            % Create ZamchejButton_2
            app.ZamchejButton_2 = uibutton(app.LeftPanel, 'push');
            app.ZamchejButton_2.ButtonPushedFcn = createCallbackFcn(app, @ZamchejButton_2Pushed, true);
            app.ZamchejButton_2.IconAlignment = 'center';
            app.ZamchejButton_2.BackgroundColor = [0.8 0.8 0.8];
            app.ZamchejButton_2.Position = [21 56 180 23];
            app.ZamchejButton_2.Text = 'Zamíchej!';

            % Create SeadseButton
            app.SeadseButton = uibutton(app.LeftPanel, 'push');
            app.SeadseButton.ButtonPushedFcn = createCallbackFcn(app, @SeadseButtonPushed, true);
            app.SeadseButton.IconAlignment = 'center';
            app.SeadseButton.BackgroundColor = [0.8 0.8 0.8];
            app.SeadseButton.FontWeight = 'bold';
            app.SeadseButton.Position = [21 26 180 23];
            app.SeadseButton.Text = 'Seřad se!';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.BackgroundColor = [1 1 1];
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.RightPanel);
            app.GridLayout3.RowHeight = {'1.25x', 116, '1x'};
            app.GridLayout3.ColumnSpacing = 8.21999104817708;
            app.GridLayout3.Padding = [8.21999104817708 10 8.21999104817708 10];

            % Create MainChart
            app.MainChart = uiaxes(app.GridLayout3);
            title(app.MainChart, 'Vizualizace třídění')
            app.MainChart.Toolbar.Visible = 'off';
            app.MainChart.FontWeight = 'bold';
            app.MainChart.XTick = [];
            app.MainChart.XTickLabel = '';
            app.MainChart.YTick = [];
            app.MainChart.YGrid = 'on';
            app.MainChart.Box = 'on';
            app.MainChart.Layout.Row = 1;
            app.MainChart.Layout.Column = [1 2];
            app.MainChart.Interruptible = 'off';
            app.MainChart.HitTest = 'off';
            app.MainChart.PickableParts = 'none';

            % Create AsymtoticksloitostPanel
            app.AsymtoticksloitostPanel = uipanel(app.GridLayout3);
            app.AsymtoticksloitostPanel.Title = 'Asymtotická složitost';
            app.AsymtoticksloitostPanel.Layout.Row = 2;
            app.AsymtoticksloitostPanel.Layout.Column = 1;
            app.AsymtoticksloitostPanel.FontWeight = 'bold';

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.AsymtoticksloitostPanel);
            app.GridLayout2.RowHeight = {'1x', '1x', '1x'};

            % Create NejhorLabel
            app.NejhorLabel = uilabel(app.GridLayout2);
            app.NejhorLabel.Layout.Row = 1;
            app.NejhorLabel.Layout.Column = 1;
            app.NejhorLabel.Text = 'Nejhorší';

            % Create NejhorsiSlozitostValue
            app.NejhorsiSlozitostValue = uilabel(app.GridLayout2);
            app.NejhorsiSlozitostValue.Interpreter = 'latex';
            app.NejhorsiSlozitostValue.FontSize = 14;
            app.NejhorsiSlozitostValue.Layout.Row = 1;
            app.NejhorsiSlozitostValue.Layout.Column = 2;
            app.NejhorsiSlozitostValue.Text = '';

            % Create PrmrnLabel
            app.PrmrnLabel = uilabel(app.GridLayout2);
            app.PrmrnLabel.Layout.Row = 2;
            app.PrmrnLabel.Layout.Column = 1;
            app.PrmrnLabel.Text = 'Průměrná';

            % Create PrumernaSlozitostValue
            app.PrumernaSlozitostValue = uilabel(app.GridLayout2);
            app.PrumernaSlozitostValue.Interpreter = 'latex';
            app.PrumernaSlozitostValue.FontSize = 14;
            app.PrumernaSlozitostValue.Layout.Row = 2;
            app.PrumernaSlozitostValue.Layout.Column = 2;
            app.PrumernaSlozitostValue.Text = {'           '; ' '};

            % Create NejlepLabel
            app.NejlepLabel = uilabel(app.GridLayout2);
            app.NejlepLabel.Layout.Row = 3;
            app.NejlepLabel.Layout.Column = 1;
            app.NejlepLabel.Text = 'Nejlepší';

            % Create NejlepsiSlozitostValue
            app.NejlepsiSlozitostValue = uilabel(app.GridLayout2);
            app.NejlepsiSlozitostValue.Interpreter = 'latex';
            app.NejlepsiSlozitostValue.FontSize = 14;
            app.NejlepsiSlozitostValue.Layout.Row = 3;
            app.NejlepsiSlozitostValue.Layout.Column = 2;
            app.NejlepsiSlozitostValue.Text = '';

            % Create MenPanel
            app.MenPanel = uipanel(app.GridLayout3);
            app.MenPanel.Title = 'Měření';
            app.MenPanel.Layout.Row = 2;
            app.MenPanel.Layout.Column = 2;
            app.MenPanel.FontWeight = 'bold';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.MenPanel);

            % Create PoetkrokLabel
            app.PoetkrokLabel = uilabel(app.GridLayout4);
            app.PoetkrokLabel.Layout.Row = 1;
            app.PoetkrokLabel.Layout.Column = 1;
            app.PoetkrokLabel.Text = 'Počet kroků';

            % Create OdvozensloitostLabel
            app.OdvozensloitostLabel = uilabel(app.GridLayout4);
            app.OdvozensloitostLabel.WordWrap = 'on';
            app.OdvozensloitostLabel.Layout.Row = 2;
            app.OdvozensloitostLabel.Layout.Column = 1;
            app.OdvozensloitostLabel.Text = 'Odvozená složitost';

            % Create PocetKroku
            app.PocetKroku = uilabel(app.GridLayout4);
            app.PocetKroku.Interpreter = 'latex';
            app.PocetKroku.FontSize = 14;
            app.PocetKroku.Layout.Row = 1;
            app.PocetKroku.Layout.Column = 2;
            app.PocetKroku.Text = '';

            % Create OdvozenaSlozitostValue
            app.OdvozenaSlozitostValue = uilabel(app.GridLayout4);
            app.OdvozenaSlozitostValue.Interpreter = 'latex';
            app.OdvozenaSlozitostValue.FontSize = 14;
            app.OdvozenaSlozitostValue.Layout.Row = 2;
            app.OdvozenaSlozitostValue.Layout.Column = 2;
            app.OdvozenaSlozitostValue.Text = '';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = sortingAlgorithmVizualizer

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
