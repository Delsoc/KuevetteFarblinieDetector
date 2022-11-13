% Main-File
% Dieser File lässt sich mit dem Befehl "Start" ausführen


% Anwendung wird initialisiert
init();

% chronologisch über alle Bilder iterieren
for img=1 : length(images)
    
    % aktuelle Bild speichern
    originalImage = images{img};

    % aktuelle Bild entzerren
    undistortedImage = undistortImage(originalImage, cameraParams);

    % Rahmenbegrenzungen der einzelnen Küvetten des aktuellen Bildes
    % ermitteln und zwischenspeichern
    [stats,centroids] = getBoundingBoxes(undistortedImage);
    
    % Rahmenbegrenzungen in firstStats speichern, bevor die
    % stats(Rahmenbegrenzungen) überarbeitet bzw. angepasst werden
    firstStats = stats;

    % Küvetten anhand der ermittelten Rahmenbegrenzungen aus dem entzerrten
    % Bild ausschneiden und zwischenspeichern
    croppedUndistortedImages = cutKuevetten(undistortedImage, stats);

    % Die ausgeschnittenen Küvetten und der aktuelle Bildindex wird
    % genutzt, um die Rahmenbegrenzungen anzupassen
    stats = adjustBoundingBoxes(stats, croppedUndistortedImages, img);
    
    % Durch die angepassten Rahmenbegrenzungen werden die Küvetten neu aus
    % dem entzerrten Bild ausgeschnitten
    recroppedUndistortedImages = cutKuevetten(undistortedImage, stats);
    
    % Innerhalb dieser Bilditeration wird nun über die ausgeschnittenen
    % Küvetten iteriert
    for croppedImg=1 : length(recroppedUndistortedImages)
        
        % Die Gesamthöhe und die Gesamtbreite der aktuellen Küvette wird
        % zwischengespeichert, welche jedoch mit den unangepassten
        % Rahmenbegrenzungen ausgeschnitten wurde
        [completeHeight, completeWidth] = size(croppedUndistortedImages{croppedImg});

        % Zeilen und Spalten bzw. Höhe und Breite der aktuellen Küvette 
        % (ausgeschnitten mit den angepassten Rahmenbegrenzungen) 
        % zwischenspeichern
        [rows, columns, numberOfColorChannels] = size(recroppedUndistortedImages{croppedImg});
    
        % houghAlgo - aktuelle Küvette in den Algorithmus 
        % "Houghtransformation" geben und die ermittelte Höhe zwischenspeichern
        calculatedHeightHough = houghAlgo3(recroppedUndistortedImages{croppedImg});
        
        % redPlaneAlgo - aktuelle Küvette in den Algorithmus 
        % "Extraktion des Rotkanals" geben und die ermittelte Höhe 
        % zwischenspeichern
        calculatedHeightRedPlane = redplaneLineAlgo(recroppedUndistortedImages{croppedImg});
        
        % saettigungsAlgo - aktuelle Küvette in den Algorithmus 
        % "Extraktion des Sättigungsalgorithmus" geben und die ermittelte 
        % Höhe zwischenspeichern
        calculatedHeightSaettigungsAlgo = saettigungsAlgo(recroppedUndistortedImages{croppedImg});
        
        % ermittelte Höhen der aktuellen Küvette pro Algorithmus in jeweils
        % eine Matrix zwischenspeichern. Außerdem komplette Höhe der
        % Küvette in eine separate Matrix speichern.
        safeHeights(calculatedHeightHough,calculatedHeightRedPlane,calculatedHeightSaettigungsAlgo,img,croppedImg, completeHeight);

    end

    % Nach der Iteration über alle Küvetten eines Bildes, die detektierten
    % Linien der 3 Algorithmen auf 3 separaten Bildern des Probenhalters
    % anzeigen. Die 3 Bilder werden in einem Figure angezeigt.
    showDetectedLines(undistortedImage, firstStats, img);
end

% Nachdem über alle Bilder iteriert wurde, werden alle ermittelten Höhen
% ausgewertet, bestimmte Größen berechnet und in den Excel-File
% "results.xlsx" geschrieben in einer Tabellenform.
calcAndSafeInExcel(length(images),str2num(expInfos{2}));
