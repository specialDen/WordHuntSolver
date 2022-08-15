close all;
clc;
clear all;
global newStr answers
answers = "";
prompt = "Enter Image url\n";
url = input(prompt,'s');
RGB = imread(url);
I = rgb2gray(RGB);
Imm = imbinarize(I,0.07);
Imm = imresize(Imm,2);
% imshow(Imm);
% saveas(gcf,'binaryImage.jpg')
% figure 
% Imm = ~Imm;
% imshow(I)
% figure
% imshow(Imm)
txt = ocr(Imm,'TextLayout','Block');
clear RGB I Imm
lines = readlines("/Users/izuchukwudennis/Developer/MatlabCodes/wordSolve/wordlist.txt");
lines = lines(matches(lines,lettersPattern));

ttt = char(txt.Text);
newStr = replace(ttt,whitespacePattern,'');
newStr = strtrim(newStr);
newStr = lower(newStr);

for i = 1:length(newStr)
    prevWord.word =  newStr(i);
    prevWord.check = true([1 length(newStr)]);
    prevWord.check(i) = false;
    prevWord.lastIndex = i;
    
    twoLetterwordStructs = getNextString(prevWord);
    for ii = 1: length(twoLetterwordStructs)
        if ii == 1
            pat = twoLetterwordStructs(ii).word;
        else
            pat = pat | twoLetterwordStructs(ii).word;
        end
    end
    dict = lines(startsWith(lines,pat));
    threeLetterwordStructs = generateNext(twoLetterwordStructs, dict);
    fourLetterwordStructs = generateNext(threeLetterwordStructs, dict);
    fiveLetterwordStructs = generateNext(fourLetterwordStructs, dict);
    sixLetterwordStructs = generateNext(fiveLetterwordStructs, dict);
    sevenLetterwordStructs = generateNext(sixLetterwordStructs, dict);
    eightLetterwordStructs = generateNext(sevenLetterwordStructs, dict);
    nineLetterwordStructs = generateNext(eightLetterwordStructs, dict);

end

answers = upper(unique(answers,'stable'));
[~,stringLength] = sort(cellfun(@length,answers),'descend');
OutputListSorted = answers(stringLength);
answerStringLenght = length(OutputListSorted);
disp(OutputListSorted)


function wordStructs = getNextString(prevWord)
    index = prevWord.lastIndex;
    switch (index)
        case 1
            indexes = [index + 1, index + 4, index + 5];
            wordStructs = getWordStruct(indexes, prevWord);
        case {2,3}
            indexes = [index + 1, index - 1, index + 3, index + 4, index + 5];
            wordStructs = getWordStruct(indexes, prevWord);
        case 4
            indexes = [index - 1, index + 3, index + 4];
            wordStructs = getWordStruct(indexes, prevWord);
        case {5,9}
            indexes = [index - 4, index - 3, index + 1, index + 4, index + 5];
            wordStructs = getWordStruct(indexes, prevWord);
        case {6,7,10,11}
            indexes = [index + 1, index - 1, index - 3, index - 4, index - 5, index + 3, index + 4, index + 5];
            wordStructs = getWordStruct(indexes, prevWord);
        case {8,12}
            indexes = [index - 4 , index - 5, index - 1, index + 3, index + 4];
            wordStructs = getWordStruct(indexes, prevWord);
        case 13
            indexes = [index + 1, index - 4, index - 5];
            wordStructs = getWordStruct(indexes, prevWord);
        case {14,15}
            indexes = [index - 1, index + 1, index - 3, index - 4, index - 5];
            wordStructs = getWordStruct(indexes, prevWord);
        case 16
            indexes = [index - 1, index - 4, index - 5];
            wordStructs = getWordStruct(indexes, prevWord);      
    end
    
end

function wordStruct = getWordStruct(indexes, prevWord)
 global newStr
    jj = 1;
    for j = 1:length(indexes)
        if prevWord.check(indexes(j))
            wordStruct(jj).word = prevWord.word + string(newStr(indexes(j)));
            wordStruct(jj).check = prevWord.check;
            wordStruct(jj).check(indexes(j)) = false;
            wordStruct(jj).lastIndex = indexes(j);
            jj = jj + 1;
        end
    end
    if jj == 1
        wordStruct(1).word = "";
        wordStruct(1).check = prevWord.check;
        wordStruct(1).lastIndex = prevWord.lastIndex;
    end
end

function wordStructs = generateNext(wordList, Dict)
global answers
    if ~isfield(wordList,'word')
        wordStructs = struct;
        return
    end
    counter = strlength(wordList(1).word);
    wordStructs1 = struct;
    for l = 1:length(wordList)
        searchWord = wordList(l).word;

        kww = startsWith(Dict,searchWord);
        kww = Dict(kww);
        matchList = matches(kww,searchWord);
        matchList = kww(matchList);
        if ~isempty(kww)
            prevWord =  wordList(l);
            if l == 1 || ~isfield(wordStructs1,'word')
                wordStructs1 = getNextString(prevWord);
            else
                tempStr = getNextString(prevWord);
                for k = 1:length(tempStr)
                    wordStructs1(end + 1) = tempStr(k);
                end
            end
            
            if counter > 2 && ~isempty(matchList)
                answers(end+1) = matchList;
            end
        end
    end
wordStructs = wordStructs1;
end
