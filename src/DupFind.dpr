program DupFind;

{$APPTYPE CONSOLE}

uses
  Classes,
  SysUtils,
  Windows;

function AddCRC(OldCRC: Integer; DataPtr: Pointer; DataSize: Integer): Integer;
const
  CRC32Table: array[0..255] of Cardinal = ($00000000, $77073096, $ee0e612c,
    $990951ba, $076dc419, $706af48f, $e963a535, $9e6495a3, $0edb8832, $79dcb8a4,
    $e0d5e91e, $97d2d988, $09b64c2b, $7eb17cbd, $e7b82d07, $90bf1d91, $1db71064,
    $6ab020f2, $f3b97148, $84be41de, $1adad47d, $6ddde4eb, $f4d4b551, $83d385c7,
    $136c9856, $646ba8c0, $fd62f97a, $8a65c9ec, $14015c4f, $63066cd9, $fa0f3d63,
    $8d080df5, $3b6e20c8, $4c69105e, $d56041e4, $a2677172, $3c03e4d1, $4b04d447,
    $d20d85fd, $a50ab56b, $35b5a8fa, $42b2986c, $dbbbc9d6, $acbcf940, $32d86ce3,
    $45df5c75, $dcd60dcf, $abd13d59, $26d930ac, $51de003a, $c8d75180, $bfd06116,
    $21b4f4b5, $56b3c423, $cfba9599, $b8bda50f, $2802b89e, $5f058808, $c60cd9b2,
    $b10be924, $2f6f7c87, $58684c11, $c1611dab, $b6662d3d, $76dc4190, $01db7106,
    $98d220bc, $efd5102a, $71b18589, $06b6b51f, $9fbfe4a5, $e8b8d433, $7807c9a2,
    $0f00f934, $9609a88e, $e10e9818, $7f6a0dbb, $086d3d2d, $91646c97, $e6635c01,
    $6b6b51f4, $1c6c6162, $856530d8, $f262004e, $6c0695ed, $1b01a57b, $8208f4c1,
    $f50fc457, $65b0d9c6, $12b7e950, $8bbeb8ea, $fcb9887c, $62dd1ddf, $15da2d49,
    $8cd37cf3, $fbd44c65, $4db26158, $3ab551ce, $a3bc0074, $d4bb30e2, $4adfa541,
    $3dd895d7, $a4d1c46d, $d3d6f4fb, $4369e96a, $346ed9fc, $ad678846, $da60b8d0,
    $44042d73, $33031de5, $aa0a4c5f, $dd0d7cc9, $5005713c, $270241aa, $be0b1010,
    $c90c2086, $5768b525, $206f85b3, $b966d409, $ce61e49f, $5edef90e, $29d9c998,
    $b0d09822, $c7d7a8b4, $59b33d17, $2eb40d81, $b7bd5c3b, $c0ba6cad, $edb88320,
    $9abfb3b6, $03b6e20c, $74b1d29a, $ead54739, $9dd277af, $04db2615, $73dc1683,
    $e3630b12, $94643b84, $0d6d6a3e, $7a6a5aa8, $e40ecf0b, $9309ff9d, $0a00ae27,
    $7d079eb1, $f00f9344, $8708a3d2, $1e01f268, $6906c2fe, $f762575d, $806567cb,
    $196c3671, $6e6b06e7, $fed41b76, $89d32be0, $10da7a5a, $67dd4acc, $f9b9df6f,
    $8ebeeff9, $17b7be43, $60b08ed5, $d6d6a3e8, $a1d1937e, $38d8c2c4, $4fdff252,
    $d1bb67f1, $a6bc5767, $3fb506dd, $48b2364b, $d80d2bda, $af0a1b4c, $36034af6,
    $41047a60, $df60efc3, $a867df55, $316e8eef, $4669be79, $cb61b38c, $bc66831a,
    $256fd2a0, $5268e236, $cc0c7795, $bb0b4703, $220216b9, $5505262f, $c5ba3bbe,
    $b2bd0b28, $2bb45a92, $5cb36a04, $c2d7ffa7, $b5d0cf31, $2cd99e8b, $5bdeae1d,
    $9b64c2b0, $ec63f226, $756aa39c, $026d930a, $9c0906a9, $eb0e363f, $72076785,
    $05005713, $95bf4a82, $e2b87a14, $7bb12bae, $0cb61b38, $92d28e9b, $e5d5be0d,
    $7cdcefb7, $0bdbdf21, $86d3d2d4, $f1d4e242, $68ddb3f8, $1fda836e, $81be16cd,
    $f6b9265b, $6fb077e1, $18b74777, $88085ae6, $ff0f6a70, $66063bca, $11010b5c,
    $8f659eff, $f862ae69, $616bffd3, $166ccf45, $a00ae278, $d70dd2ee, $4e048354,
    $3903b3c2, $a7672661, $d06016f7, $4969474d, $3e6e77db, $aed16a4a, $d9d65adc,
    $40df0b66, $37d83bf0, $a9bcae53, $debb9ec5, $47b2cf7f, $30b5ffe9, $bdbdf21c,
    $cabac28a, $53b39330, $24b4a3a6, $bad03605, $cdd70693, $54de5729, $23d967bf,
    $b3667a2e, $c4614ab8, $5d681b02, $2a6f2b94, $b40bbe37, $c30c8ea1, $5a05df1b,
    $2d02ef8d);
var
  EndOfData, Source: PChar;
  Value: Integer;
const
  Tail: array[0..3] of Integer = (0, 3, 2, 1);
begin
  Result := OldCRC;
  if DataSize = 0 then
    Exit;
  Source := PChar(DataPtr);
  EndOfData := Source + DataSize + Tail[DataSize and 3];
  while Source < EndOfData do
  begin
    Value := PInteger(Source)^;
    Result := (Result shr 8) xor Integer(CRC32Table[(Result xor (Value and 255))
      and $FF]);
    Value := Value shr 8;
    Result := (Result shr 8) xor Integer(CRC32Table[(Result xor (Value and 255))
      and $FF]);
    Value := Value shr 8;
    Result := (Result shr 8) xor Integer(CRC32Table[(Result xor (Value and 255))
      and $FF]);
    Value := Value shr 8;
    Result := (Result shr 8) xor Integer(CRC32Table[(Result xor (Value and 255))
      and $FF]);
    Inc(Source, 4);
  end;
end;

type
  Tkeep = packed record
    len: ShortInt;
    txt: array[0..MAXWORD] of WideChar;
  end;

  Pkeep = ^Tkeep;

  Thave = packed record
    size: Integer;
    high, low: Cardinal;
    name: array[0..MAXWORD] of WideChar;
  end;

  Phave = ^Thave;

procedure process(cur: WideString = ''; me: AnsiString = ''; rel: WideString = '');
var
  find: WideString;
  data: _WIN32_FIND_DATAW;
  res, len, i: Integer;
  list: TList;
  keep: Pkeep;
begin
  if cur = '' then
  begin
    SetLength(cur, GetCurrentDirectoryW(0, nil));
    GetCurrentDirectoryW(Length(cur), PWChar(cur));
    cur[Length(cur)] := '\';
    me := UTF8Encode(cur);
    WriteLn(ErrOutput, 'Current: "', cur, '"');
    cur := '';
    rel := '\';
  end
  else
  begin
    rel := rel + cur + '\';
    if not SetCurrentDirectoryW(PWChar(cur)) then
    begin
      WriteLn(ErrOutput, 'Fail: "', rel, '"');
      Exit;
    end;
    me := me + UTF8Encode(cur) + '\';
    WriteLn(ErrOutput, 'Next: "', rel, '"');
  end;
  find := '*';
  res := FindFirstFileW(PWideChar(find), data);
  if (res = 0) or (res = -1) then
    Exit;
  list := TList.Create();
  repeat
    if (data.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) > 0 then
    begin
      if data.cFileName[0] = '.' then
      begin
        if data.cFileName[1] = #0 then
          Continue;
        if (data.cFileName[1] = '.') and (data.cFileName[2] = #0) then
          Continue;
      end;
      len := (Length(PWChar(@data.cFileName[0])) + 1) * 2;
      GetMem(keep, len + 2);
      keep.len := len;
      Move(data.cFileName, keep.txt, len);
      list.Add(keep);
      WriteLn(ErrOutput, 'Dir: "', data.cFileName, '"');
    end
    else if (data.nFileSizeHigh = 0) and (Integer(data.nFileSizeLow) > 0) then
    begin
      Writeln(data.nFileSizeLow, #9'$', IntToHex(data.ftCreationTime.dwHighDateTime,
        8), ' $', IntToHex(data.ftCreationTime.dwLowDateTime, 8), #9, me,
        UTF8Encode(data.cFileName));
      WriteLn(ErrOutput, 'File: "', data.cFileName, '"');
    end
    else
      WriteLn(ErrOutput, 'Ignore: "', data.cFileName, '"');
  until not FindNextFileW(res, data);
  FindClose(res);
  for i := 0 to list.Count - 1 do
  begin
    process(Pkeep(list.Items[i]).txt, me, rel);
    FreeMem(list.Items[i]);
  end;
  list.Free();
  if cur <> '' then
    SetCurrentDirectoryW(PWChar(WideString('..')));
end;

procedure use(var val);
begin
  //
end;

function crc(f: PWideChar): Integer;
var
  s: THandleStream;
  h: Integer;
  buf: array[0..65535] of Byte;
begin
  s := nil;
  h := 0;
  try
    h := CreateFileW(f, GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil,
      OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, 0);
    if (h = 0) or (h = -1) then
      Abort;
    s := THandleStream.Create(h);
    FillChar(buf, SizeOf(buf), #0);
    Result := -1;
    while (s.Position < s.Size) do
      Result := AddCRC(Result, @buf[0], s.Read(buf, SizeOf(buf)));
  except
    Result := 0;
  end;
  s.Free();
  if (h <> 0) and (h <> -1) then
    CloseHandle(h);
end;

function diff(f1, f2: PWideChar): Boolean;
var
  s1, s2: THandleStream;
  h1, h2: Integer;
  buf1, buf2: array[0..65535] of Byte;
  size: Integer;
begin
  Result := False;
  s1 := nil;
  s2 := nil;
  h1 := 0;
  h2 := 0;
  try
    h1 := CreateFileW(f1, GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil,
      OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, 0);
    h2 := CreateFileW(f2, GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil,
      OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, 0);
    if (h1 = 0) or (h1 = -1) or (h2 = 0) or (h2 = -1) then
      Abort;
    s1 := THandleStream.Create(h1);
    s2 := THandleStream.Create(h2);
    while (s1.Position < s1.Size) and (s2.Position < s2.Size) do
    begin
      size := s1.Read(buf1, SizeOf(buf1));
      if (s2.Read(buf2, SizeOf(buf2)) <> size) then
        Abort;
      if (size > 0) and not CompareMem(@buf1[0], @buf2[0], size) then
        Abort;
    end;
    Result := True;
  except
  end;
  s1.Free();
  s2.Free();
  if (h1 <> 0) and (h1 <> -1) then
    CloseHandle(h1);
  if (h2 <> 0) and (h2 <> -1) then
    CloseHandle(h2);
end;

function compare(p1, p2: Pointer): Integer;
var
  h1, h2: Phave;
begin
  h1 := p1;
  h2 := p2;
  Result := h2.size - h1.size;
  if Result = 0 then
  begin
    Result := h2.high - h1.high;
    if Result = 0 then
      Result := h2.low - h1.low;
  end;
end;

function pref(p, s: WideString): WideString;
begin
  Result := s;
  if Length(p) >= Length(s) then
    Exit;
  if CompareMem(PWChar(p), PWChar(s), Length(p) * 2) then
    Result := Copy(s, Length(p) + 1, Length(s) - Length(p));
end;

{$I-}
procedure combine();
var
  size: Integer;
  high, low: Cardinal;
  path: AnsiString;
  list: TList;
  have: Phave;
  cur: WideString;
  i, j, k: Integer;
  flag: Boolean;
begin
  list := TList.Create();
  Writeln(ErrOutput, 'Reading data...');
  while True do
  begin
    size := 0;
    use(size);
    Readln(size, high, low, path);
    if (size = 0) or (IOResult <> 0) or Eof(Input) then
      Break;
    cur := UTF8Decode(Trim(path));
    GetMem(have, 4 + 8 + (Length(cur) + 1) * 2);
    have.size := size;
    have.high := high;
    have.low := low;
    Move(PWChar(cur)^, have.name, (Length(cur) + 1) * 2);
    list.Add(have);
  end;
  Writeln(ErrOutput, 'Got: ', list.Count);
  if list.Count > 0 then
  begin
    list.Sort(compare);
    Writeln(ErrOutput, 'Sorted!');
  end;
  SetLength(cur, GetCurrentDirectoryW(0, nil));
  GetCurrentDirectoryW(Length(cur), PWChar(cur));
  cur[Length(cur)] := '\';
  Writeln(ErrOutput, 'Current directory: "', cur, '"');
  i := 0;
  if list.Count > 0 then
    while True do
    begin
      if i = list.Count - 1 then
      begin
        Writeln(ErrOutput, 'Unique: "', pref(cur, Phave(list.Items[i]).name), '"');
        FreeMem(list.Items[i]);
        Break;
      end;
      Inc(i);
      if Phave(list.Items[i - 1]).size <> Phave(list.Items[i]).size then
      begin
        Writeln(ErrOutput, 'Unique: "', pref(cur, Phave(list.Items[i - 1]).name), '"');
        FreeMem(list.Items[i - 1]);
        Continue;
      end;
      if (i = list.Count - 1) or (Phave(list.Items[i + 1]).size <> Phave(list.Items
        [i]).size) then
      begin
        Writeln(ErrOutput, 'Compare: "', pref(cur, Phave(list.Items[i - 1]).name),
          '" + "', pref(cur, Phave(list.Items[i]).name), '"');
        if diff(Phave(list.Items[i - 1]).name, Phave(list.Items[i]).name) then
        begin
          Writeln(Utf8encode(Phave(list.Items[i - 1]).name));
          Writeln(ErrOutput, 'Same!');
        end
        else
          Writeln(ErrOutput, 'Different.');
        FreeMem(list.Items[i - 1]);
        Continue;
      end;
      size := Phave(list.Items[i]).size;
      j := i - 1;
      repeat
        Inc(i);
      until (i = list.Count) or (Phave(list.Items[i]).size <> size);
      Dec(i);
      for k := j to i do
      begin
        Writeln(ErrOutput, 'CRC: "' + pref(cur, Phave(list.Items[k]).name) + '"');
        Phave(list.Items[k]).size := crc(Phave(list.Items[k]).name);
      end;
      while j < i do
      begin
        k := j;
        flag := True;
        repeat
          Inc(k);
          if (Phave(list.Items[j]).size = Phave(list.Items[k]).size) then
          begin
            Writeln(ErrOutput, 'Compare: "', pref(cur, Phave(list.Items[j]).name),
              '" + "', pref(cur, Phave(list.Items[k]).name), '"');
            if diff(Phave(list.Items[j]).name, Phave(list.Items[k]).name) then
            begin
              Writeln(Utf8encode(Phave(list.Items[j]).name));
              Writeln(ErrOutput, 'Same!');
              flag := False;
              Break;
            end
            else
              Writeln(ErrOutput, 'Different.');
          end;
        until k > i;
        if flag then
          Writeln(ErrOutput, 'Unique: "', pref(cur, Phave(list.Items[j]).name), '"');
        FreeMem(list.Items[j]);
        Inc(j);
      end;
    end;
  list.Free();
end;

procedure rename(prf, suf: string);
var
  name: AnsiString;
  cur, new: WideString;
  i: Integer;
begin
  WriteLn(ErrOutput, 'Suffix: "', prf, '*', suf, '"');
  while True do
  begin
    name := #0;
    use(name);
    Readln(name);
    if (name = #0) or (IOResult <> 0) or (Eof(Input)) then
      Exit;
    cur := UTF8Decode(Trim(name));
    new := '';
    for i := Length(cur) downto 1 do
      if cur[i] = '\' then
      begin
        new := Copy(cur, 1, i) + prf + Copy(cur, i + 1, Length(cur) - i) + suf;
        Break;
      end;
    if (new <> '') and MoveFileW(PWChar(cur), PWChar(new)) then
    begin
      WriteLn(ErrOutput, 'Renamed: "', cur, '"');
      WriteLn(UTF8Encode(new));
    end
    else
      WriteLn(ErrOutput, 'Failed: "', cur, '"');
  end;
end;

var
  com, prf, suf, s: string;

begin
  WriteLn(ErrOutput, 'DupFind v1.1, by Kly_Men_COmpany!');
  if ParamCount = 0 then
  begin
    s := '';  
{(*}
s:=s+'This program can search for file duplicates.'#10;
s:=s+'It detects the exact same files across directory tree and renames them.'#10;
s:=s+'So you can manually seek and delete by prefixed name.'#10;
s:=s+''#10;
s:=s+'There are three stages of work:'#10;
s:=s+'1) Build global list of files;'#10;
s:=s+'2) Check duplicates and combine them to another list;'#10;
s:=s+'3) Rename all files in that list.'#10;
s:=s+''#10;
s:=s+'DupFind.exe must be called from MS cmd.exe prompt console window.'#10;
s:=s+'This program highly uses stdin/stdout streams.'#10;
s:=s+'Data sent to standard output are encoded in UTF-8.'#10;
s:=s+'Messages displayed via stderr are just wide-strings, may look garbage.'#10;
s:=s+'You should put this program to PATH (or a system dir) so you'#10;
s:=s+'    can use short form when calling commands (or just copy it to current dir).'#10;
s:=s+'Original file is one that have most old creation time mark, every other'#10;
s:=s+'  more recent files are considered duplicated (if they have the same content).'#10;
s:=s+'Empty files with zero size are ignored, just as files larger than 2 Gb.'#10;
s:=s+'Compare process starts from big files and end with small ones.'#10;
s:=s+''#10;
s:=s+'FIRST STAGE: build list of files.'#10;
s:=s+'- go to your target folder (cd /d "E:\photo\"), make it "current directory".'#10;
s:=s+'- all files and subfolders will be processed recursively.'#10;
s:=s+'- execute there "DupFind.exe /L >list.txt" (output redirected to a file).'#10;
s:=s+'- you will got "list.txt" (or whatever) with all data need for next stage.'#10;
s:=s+'- BONUS: you can execute that in several distinct directories,'#10;
s:=s+'    and then combine all output (f.e. with ">>") into one file!'#10;
s:=s+''#10;
s:=s+'SECOND STAGE: reading and comparing files.'#10;
s:=s+'- you need your filelist from previous stage.'#10;
s:=s+'- current directory doesn`t actually matters, but if it will be the same as'#10;
s:=s+'    it was before, then you will have move informative log on the screen.'#10;
s:=s+'- execute there "DupFind.exe /F <list.txt >res.txt" (input also redirected).'#10;
s:=s+'- you will got new "res.txt" with plain list of file duplicates.'#10;
s:=s+'- there is no info about where is an original file, but it was in a'#10;
s:=s+'    printed log (you may redirect that too, like "2>log.txt").'#10;
s:=s+''#10;
s:=s+'THIRD STAGE: actually rename files.'#10;
s:=s+'- you should provide a prefix and a suffix to use as new names.'#10;
s:=s+'- get your result from previous stage (list of files to rename, absolute path).'#10;
s:=s+'- execute anywhere:  "DupFind.exe /R @_ .OLD <res.txt >done.txt".'#10;
s:=s+'- here "@_" is a prefix (appended from left) and ".OLD" - suffix (from right).'#10;
s:=s+'- result document "done.txt" will contain the same but renamed filelist.'#10;
s:=s+'- all files will be renamed, it possible.'#10;
s:=s+'- now you can use standard search to seek for "@_*.OLD" and delete them!'#10;
s:=s+''#10;
s:=s+'ALL STAGES IN ONE: quick work, without intermediate lists.'#10;
s:=s+'- go to your target folder, open console window there.'#10;
s:=s+'- execute this command: "DupFind L|DupFind F|DupFind R *",'#10;
s:=s+'    but instead of * put your desired prefix, for example $$$_'#10;
s:=s+'- you will have a log of everything on screen. But files will be renamed!'#10;
s:=s+'- to have at least a list of duplicates, append " >dup.txt" to your command.'#10;
s:=s+''#10;
s:=s+'More formal usage parameters:'#10;
s:=s+'(All arguments are case-insensitive, also "/" may be "-" or omitted).'#10;
s:=s+''#10;
s:=s+'DupFind /L'#10;
s:=s+'DupFind /LIST'#10;
s:=s+'- recursively searches starting from current directory.'#10;
s:=s+'Prints to stdout info for all good files:'#10;
s:=s+'SIZE	$HI $LO	NAME'#10;
s:=s+'Where SIZE = file size, decimal; $HI and $LO = hexadecimal encoded'#10;
s:=s+'    file creation date (file-time format); NAME = absolute path to a file.'#10;
s:=s+'Prints to stderr these messages:'#10;
s:=s+'"Listing start." / "Listing done." - start and finish of execution;'#10;
s:=s+'"Current: *" - root directory for this search;'#10;
s:=s+'"Dir: *" - subfolder is found and added to recursive queue;'#10;
s:=s+'"File: *" - a file is found and printed to stdout.'#10;
s:=s+'"Ignore: *" - not good file (empty or too large), skipping;'#10;
s:=s+'"Fail: *" - cannot enter a directory;'#10;
s:=s+''#10;
s:=s+'DupFind /F'#10;
s:=s+'DupFind /FIND'#10;
s:=s+'- reads text from standard input according to format above.'#10;
s:=s+'Empty lines and spaces are ignored.'#10;
s:=s+'Here is how the list is handled (stderr messages):'#10;
s:=s+'"Working start." / "Working done." - start and finish of execution;'#10;
s:=s+'"Reading data..." - read from stdin until there is no more text or an error.'#10;
s:=s+'"Got: *" - done, prints how mush filenames it have. Sorting starts.'#10;
s:=s+'"Sorted!" - when list sorting is done.'#10;
s:=s+'"Current directory: *" - following messages will omit this if begins with.'#10;
s:=s+'"Unique: *" - a file that will be preserves, an "original".'#10;
s:=s+'"Compare: * + *" – when there are only two files with exact this size,'#10;
s:=s+'    there is no need to calculate CRC. They will be compared by contents.'#10;
s:=s+'"Same!" - previous files compared and duplicates, first one is outputted.'#10;
s:=s+'"Different." - despite having the same size, they have differences in content.'#10;
s:=s+'"CRC: *" - there are three or more files with the same size.'#10;
s:=s+'    Need to calculate CRC for each one. Next there will be several "Compare"s,'#10;
s:=s+'    between files with equal hashes. Result is marked as "Unique" too.'#10;
s:=s+''#10;
s:=s+'DupFind /R [pref [suff]]'#10;
s:=s+'DupFind /REN [pref [suff]]'#10;
s:=s+'DupFind /RENAME [pref [suff]]'#10;
s:=s+'- where "pref" and "suff" are strings to rename with.'#10;
s:=s+'Make sure you use a correct values, that allowed in file names!'#10;
s:=s+'If you need to specify only suffix, put "*" for prefix.'#10;
s:=s+'Program will read filenames from stdin, and try to rename'#10;
s:=s+'  each one (with respect to absolute path) but adding your'#10;
s:=s+'  prefix and suffix. Renamed version of filenames is printed to stdout.'#10;
s:=s+'Messages sent to stderr:'#10;
s:=s+'"Rename start." / "Rename done." - start and finish of execution;'#10;
s:=s+'"Suffix: PREF*SUFF" - shows yours arguments;'#10;
s:=s+'"Renamed: *" - original file that is successfully renamed;'#10;
s:=s+'"Failed: *" - a file that was unable to rename.'#10;
s:=s+''#10;
s:=s+'There may be also these error messages:'#10;
s:=s+'"Exception: *" - runtime error with a message. Program terminated.'#10;
s:=s+'"Error: wrong mode!" - too much arguments specified.'#10;
s:=s+'"Error: wrong mode: *" - your first argument is invalid.'#10;
s:=s+'"Error: empty suffix for rename!" - no prefix for rename mode.'#10;
s:=s+'"Error: wrong suffix definition!" - bad rename strings.'#10;
s:=s+''#10;
s:=s+'End of DupFind help.'#10;
{*)}
    WriteLn(ErrOutput, s);
    Exit;
  end;
  com := UpperCase(ParamStr(1));
  if (com[1] = '/') or (com[1] = '-') then
    Delete(com, 1, 1);
  if (com = 'L') or (com = 'LIST') then
  begin
    if ParamCount > 1 then
    begin
      WriteLn(ErrOutput, 'Error: wrong mode!');
      Exit;
    end;
    WriteLn(ErrOutput, 'Listing start.');
    try
      process();
    except
      on E: Exception do
        WriteLn(ErrOutput, 'Exception: ', E.message);
    end;
    WriteLn(ErrOutput, 'Listing done.');
  end
  else if (com = 'F') or (com = 'FIND') then
  begin
    if ParamCount > 1 then
    begin
      WriteLn(ErrOutput, 'Error: wrong mode!');
      Exit;
    end;
    WriteLn(ErrOutput, 'Working start.');
    try
      combine();
    except
      on E: Exception do
        WriteLn(ErrOutput, 'Exception: ', E.message);
    end;
    WriteLn(ErrOutput, 'Working done.');
  end
  else if (com = 'R') or (com = 'REN') or (com = 'RENAME') then
  begin
    prf := ParamStr(2);
    if prf = '*' then
      prf := '';
    suf := ParamStr(3);
    if prf + suf = '' then
    begin
      WriteLn(ErrOutput, 'Error: empty suffix for rename!');
      Exit;
    end;
    if (ParamCount > 3) or (Pos('/', prf) > 0) or (Pos('/', suf) > 0) then
    begin
      WriteLn(ErrOutput, 'Error: wrong suffix definition!');
      Exit;
    end;
    WriteLn(ErrOutput, 'Rename start.');
    try
      rename(prf, suf);
    except
      on E: Exception do
        WriteLn(ErrOutput, 'Exception: ', E.message);
    end;
    WriteLn(ErrOutput, 'Rename done.');
  end
  else
  begin
    WriteLn(ErrOutput, 'Error: wrong mode: "' + ParamStr(1) + '"');
  end;
end.

