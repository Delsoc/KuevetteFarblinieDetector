function [calculatedHeight] = houghAlgo3(RGB)
% Diese Funktion erwartet als Eingabe das ausgeschnittene Bild der Küvette.
% Es wird das Verfahren "Hough-Transformation" angewendet, um die Höhe der
% gewünschten Linie zu detektieren
    
    % Die Höhe des Eingabebildes wird ausgelesen
    [hoehe,~] = size(RGB);

    % Aus dem Farbbild wird ein Grauwertbild genertiert, indem der Rotkanal
    % extrahiert wird
    R = RGB(:,:,1);

    % Die Anzahl der Zeilen und Spalten des Bildes wird ausgelesen
    [rows, columns, ~] = size(R);

    % Das Komplementärbild wird erstellt
    Bimage = imcomplement(R);

    % Auf das Komplementärbild wird der Prewitt-Operator angewendet und
    % somit ein Kantenbild erstellt
    BW = edge(Bimage,'prewitt');

    % Das Kantenbild wird in der Höhe um 25% gekürzt
    BW = imcrop(BW, [0 rows*0.25 columns rows]);

    % Hough-Transformation wird angewendet und H, theta, rho
    % zwischengespeichert
    [H, theta, rho] = hough(BW);

    % Houghpeaks finden
    P = houghpeaks(H,3,'threshold',ceil(0.5*max(H(:))));

    % theatas finden
    x = theta(P(:,2));

    % rhos finden
    y = rho(P(:,1));

    % Linien finden
    lines = houghlines(BW, theta, rho, P, 'FillGap',6,'MinLength',4);
    
    % variablen mit 0 initialisieren
    calculatedHeight = 0;
    countedHeightPoints = 0;

    % Über alle Linien iterieren
    for k = 1:length(lines)

        % x- und y-Wert des Anfangs und des Ende der Linie in xy speichern
        xy = [lines(k).point1; lines(k).point2];
       
        % Plot beginnings and ends of lines
        
        % Beide Höhen abspeichern
        y1 = xy(1,2);
        y2 = xy(2,2);

        % Durchschnittliche Höhe berechnen
        lineFocusWeight = (y1 + y2)/2;

        if ((lineFocusWeight < (0.90 * rows)) && (lineFocusWeight > (0) * rows))
            % Bedingung erfüllt, wenn durchschnittliche Höhe der Linie
            % innerhalb der unteren 90% Höhe des Eingabebildes

            % Höhe bestimmen/berechnen
            calculatedHeight = calculatedHeight + lineFocusWeight + rows*0.25;

            % Anzahl der gefundenen Linien um 1 inkrementieren
            countedHeightPoints = countedHeightPoints + 1;

        end

    end
    
    if(calculatedHeight > 0)
        % Bedingung erfüllt, wenn Linien gefunden wurden

        % summierte Höhe durch Anzahl der gefundenen Linien dividieren
        calculatedHeight = calculatedHeight / countedHeightPoints;
        
        % Höhe korrigieren 
        calculatedHeight = hoehe - calculatedHeight;
    end
end









