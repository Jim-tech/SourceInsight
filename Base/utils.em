/* Utils.em - a small collection of useful editing macros */



/*-------------------------------------------------------------------------
	I N S E R T   H E A D E R

	Inserts a comment header block at the top of the current function. 
	This actually works on any type of symbol, not just functions.

	To use this, define an environment variable "MYNAME" and set it
	to your email name.  eg. set MYNAME=raygr
-------------------------------------------------------------------------*/
macro InsertHeader()
{
	// Get the owner's name from the environment variable: MYNAME.
	// If the variable doesn't exist, then the owner field is skipped.
	szMyName = getenv(MYNAME)
	
	// Get a handle to the current file buffer and the name
	// and location of the current symbol where the cursor is.
	hbuf = GetCurrentBuf()
	szFunc = GetCurSymbol()
	ln = GetSymbolLine(szFunc)

	// begin assembling the title string
	sz = "/*   "
	
	/* convert symbol name to T E X T   L I K E   T H I S */
	cch = strlen(szFunc)
	ich = 0
	while (ich < cch)
		{
		ch = szFunc[ich]
		if (ich > 0)
			if (isupper(ch))
				sz = cat(sz, "   ")
			else
				sz = cat(sz, " ")
		sz = Cat(sz, toupper(ch))
		ich = ich + 1
		}
	
	sz = Cat(sz, "   */")
	InsBufLine(hbuf, ln, sz)
	InsBufLine(hbuf, ln+1, "/*-------------------------------------------------------------------------")
	
	/* if owner variable exists, insert Owner: name */
	if (strlen(szMyName) > 0)
		{
		InsBufLine(hbuf, ln+2, "    Owner: @szMyName@")
		InsBufLine(hbuf, ln+3, " ")
		ln = ln + 4
		}
	else
		ln = ln + 2
	
	InsBufLine(hbuf, ln,   "    ") // provide an indent already
	InsBufLine(hbuf, ln+1, "-------------------------------------------------------------------------*/")
	
	// put the insertion point inside the header comment
	SetBufIns(hbuf, ln, 4)
}


/* InsertFileHeader:

   Inserts a comment header block at the top of the current function. 
   This actually works on any type of symbol, not just functions.

   To use this, define an environment variable "MYNAME" and set it
   to your email name.  eg. set MYNAME=raygr
*/

macro InsertFileHeader()
{
	szMyName = getenv(MYNAME)
	
	hbuf = GetCurrentBuf()

	InsBufLine(hbuf, 0, "/*-------------------------------------------------------------------------")
	
	/* if owner variable exists, insert Owner: name */
	InsBufLine(hbuf, 1, "    ")
	if (strlen(szMyName) > 0)
		{
		sz = "    Owner: @szMyName@"
		InsBufLine(hbuf, 2, " ")
		InsBufLine(hbuf, 3, sz)
		ln = 4
		}
	else
		ln = 2
	
	InsBufLine(hbuf, ln, "-------------------------------------------------------------------------*/")
}



// Inserts "Returns True .. or False..." at the current line
macro ReturnTrueOrFalse()
{
	hbuf = GetCurrentBuf()
	ln = GetBufLineCur(hbuf)

	InsBufLine(hbuf, ln, "    Returns True if successful or False if errors.")
}



/* Inserts ifdef REVIEW around the selection */
macro IfdefReview()
{
	IfdefSz("REVIEW");
}


/* Inserts ifdef BOGUS around the selection */
macro IfdefBogus()
{
	IfdefSz("BOGUS");
}


/* Inserts ifdef NEVER around the selection */
macro IfdefNever()
{
	IfdefSz("NEVER");
}


// Ask user for ifdef condition and wrap it around current
// selection.
macro InsertIfdef()
{
	sz = Ask("Enter ifdef condition:")
	if (sz != "")
		IfdefSz(sz);
}

macro InsertCPlusPlus()
{
	IfdefSz("__cplusplus");
}


// Wrap ifdef <sz> .. endif around the current selection
macro IfdefSz(sz)
{
	hwnd = GetCurrentWnd()
	lnFirst = GetWndSelLnFirst(hwnd)
	lnLast = GetWndSelLnLast(hwnd)
	 
	hbuf = GetCurrentBuf()
	InsBufLine(hbuf, lnFirst, "#ifdef @sz@")
	InsBufLine(hbuf, lnLast+2, "#endif /* @sz@ */")
}


// Delete the current line and appends it to the clipboard buffer
macro KillLine()
{
	hbufCur = GetCurrentBuf();
	lnCur = GetBufLnCur(hbufCur)
	hbufClip = GetBufHandle("Clipboard")
	AppendBufLine(hbufClip, GetBufLine(hbufCur, lnCur))
	DelBufLine(hbufCur, lnCur)
}


// Paste lines killed with KillLine (clipboard is emptied)
macro PasteKillLine()
{
	Paste
	EmptyBuf(GetBufHandle("Clipboard"))
}



// delete all lines in the buffer
macro EmptyBuf(hbuf)
{
	lnMax = GetBufLineCount(hbuf)
	while (lnMax > 0)
		{
		DelBufLine(hbuf, 0)
		lnMax = lnMax - 1
		}
}


// Ask the user for a symbol name, then jump to its declaration
macro JumpAnywhere()
{
	symbol = Ask("What declaration would you like to see?")
	JumpToSymbolDef(symbol)
}

	
// list all siblings of a user specified symbol
// A sibling is any other symbol declared in the same file.
macro OutputSiblingSymbols()
{
	symbol = Ask("What symbol would you like to list siblings for?")
	hbuf = ListAllSiblings(symbol)
	SetCurrentBuf(hbuf)
}


// Given a symbol name, open the file its declared in and 
// create a new output buffer listing all of the symbols declared
// in that file.  Returns the new buffer handle.
macro ListAllSiblings(symbol)
{
	loc = GetSymbolLocation(symbol)
	if (loc == "")
		{
		msg ("@symbol@ not found.")
		stop
		}
	
	hbufOutput = NewBuf("Results")
	
	hbuf = OpenBuf(loc.file)
	if (hbuf == 0)
		{
		msg ("Can't open file.")
		stop
		}
		
	isymMax = GetBufSymCount(hbuf)
	isym = 0;
	while (isym < isymMax)
		{
		AppendBufLine(hbufOutput, GetBufSymName(hbuf, isym))
		isym = isym + 1
		}

	CloseBuf(hbuf)
	
	return hbufOutput

}

macro SuperBackspace()
{
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();
    if (hbuf == 0)
        stop;   // empty buffer
    // get current cursor postion
    ipos = GetWndSelIchFirst(hwnd);
    // get current line number
    ln = GetBufLnCur(hbuf);
    if ((GetBufSelText(hbuf) != "") || (GetWndSelLnFirst(hwnd) != GetWndSelLnLast(hwnd))) {
        // sth. was selected, del selection
        SetBufSelText(hbuf, " "); // stupid & buggy sourceinsight :(
        // del the " "
        SuperBackspace(1);
        stop;
    }
    // copy current line
    text = GetBufLine(hbuf, ln);
    // get string length
    len = strlen(text);
    // if the cursor is at the start of line, combine with prev line
    if (ipos == 0 || len == 0) {
        if (ln <= 0)
            stop;   // top of file
        ln = ln - 1;    // do not use "ln--" for compatibility with older versions
        prevline = GetBufLine(hbuf, ln);
        prevlen = strlen(prevline);
        // combine two lines
        text = cat(prevline, text);
        // del two lines
        DelBufLine(hbuf, ln);
        DelBufLine(hbuf, ln);
        // insert the combined one
        InsBufLine(hbuf, ln, text);
        // set the cursor position
        SetBufIns(hbuf, ln, prevlen);
        stop;
    }
    num = 1; // del one char
    if (ipos >= 1) {
        // process Chinese character
        i = ipos;
        count = 0;
        while (AsciiFromChar(text[i - 1]) >= 160) {
            i = i - 1;
            count = count + 1;
            if (i == 0)
                break;
        }
        if (count > 0) {
            // I think it might be a two-byte character
            num = 2;
            // This idiot does not support mod and bitwise operators
            if ((count / 2 * 2 != count) && (ipos < len))
                ipos = ipos + 1;    // adjust cursor position
        }
    }
    // keeping safe
    if (ipos - num < 0)
        num = ipos;
    // del char(s)
    text = cat(strmid(text, 0, ipos - num), strmid(text, ipos, len));
    DelBufLine(hbuf, ln);
    InsBufLine(hbuf, ln, text);
    SetBufIns(hbuf, ln, ipos - num);
    stop;
}

macro SuperDelete()
{
    hwnd = GetCurrentWnd();
    hbuf = GetCurrentBuf();
    if (hbuf == 0)
        stop;   // empty buffer
    // get current cursor postion
    ipos = GetWndSelIchFirst(hwnd);
    // get current line number
    ln = GetBufLnCur(hbuf);
    if ((GetBufSelText(hbuf) != "") || (GetWndSelLnFirst(hwnd) != GetWndSelLnLast(hwnd))) {
        // sth. was selected, del selection
        SetBufSelText(hbuf, " "); // stupid & buggy sourceinsight :(
        // del the " "
        SuperDelete(1);
        stop;
    }
    // copy current line
    text = GetBufLine(hbuf, ln);
    // get string length
    len = strlen(text);
    if (ipos == len || len == 0) {
		totalLn = GetBufLineCount (hbuf);
		lastText = GetBufLine(hBuf, totalLn-1);
		lastLen = strlen(lastText);
        if (ipos == lastLen)// end of file
   stop;
        ln = ln + 1;    // do not use "ln--" for compatibility with older versions
        nextline = GetBufLine(hbuf, ln);
        nextlen = strlen(nextline);
        // combine two lines
        text = cat(text, nextline);
        // del two lines
        DelBufLine(hbuf, ln-1);
        DelBufLine(hbuf, ln-1);
        // insert the combined one
        InsBufLine(hbuf, ln-1, text);
        // set the cursor position
        SetBufIns(hbuf, ln-1, len);
        stop;
    }
    num = 1; // del one char
    if (ipos > 0) {
        // process Chinese character
        i = ipos;
        count = 0;
        while (AsciiFromChar(text[i-1]) >= 160) {
            i = i - 1;
            count = count + 1;
            if (i == 0)
                break;
        }
        if (count > 0) {
            // I think it might be a two-byte character
            num = 2;
            // This idiot does not support mod and bitwise operators
            if (((count / 2 * 2 != count) || count == 0) && (ipos < len-1))
                ipos = ipos + 1;    // adjust cursor position
        }
		// keeping safe
		if (ipos - num < 0)
		            num = ipos;
		    }
		    else {
			i = ipos;
			count = 0;
			while(AsciiFromChar(text[i]) >= 160) {
		     i = i + 1;
		     count = count + 1;
		     if(i == len-1)
		   break;
		}
		if(count > 0) {
		     num = 2;
		}
    }
    text = cat(strmid(text, 0, ipos), strmid(text, ipos+num, len));
    DelBufLine(hbuf, ln);
    InsBufLine(hbuf, ln, text);
    SetBufIns(hbuf, ln, ipos);
    stop;
}

macro IsComplexCharacter()
{
	hwnd = GetCurrentWnd();
	hbuf = GetCurrentBuf();
	if (hbuf == 0)
	   return 0;
	//当前位置
	pos = GetWndSelIchFirst(hwnd);
	//当前行数
	ln = GetBufLnCur(hbuf);
	//得到当前行
	text = GetBufLine(hbuf, ln);
	//得到当前行长度
	len = strlen(text);
	//从头计算汉字字符的个数
	if(pos > 0)
	{
	   i=pos;
	   count=0;
	   while(AsciiFromChar(text[i-1]) >= 160)
	   { 
	    i = i - 1;
	    count = count+1;
	    if(i == 0) 
	     break;
	   }
	   if((count/2)*2==count|| count==0)
	    return 0;
	   else
	    return 1;
	}
	return 0;
}
macro moveleft()
{
	hwnd = GetCurrentWnd();
	hbuf = GetCurrentBuf();
	if (hbuf == 0)
	        stop;   // empty buffer
	ln = GetBufLnCur(hbuf);
	ipos = GetWndSelIchFirst(hwnd);
	if(GetBufSelText(hbuf) != "" || (ipos == 0 && ln == 0))   // 第0行或者是选中文字,则不移动
	{
	   SetBufIns(hbuf, ln, ipos);
	   stop;
	}
	if(ipos == 0)
	{
	   preLine = GetBufLine(hbuf, ln-1);
	   SetBufIns(hBuf, ln-1, strlen(preLine)-1);
	}
	else
	{
	   SetBufIns(hBuf, ln, ipos-1);
	}
}
macro SuperCursorLeft()
{
	moveleft();
	if(IsComplexCharacter())
	   moveleft();
}

macro moveRight()
{
	hwnd = GetCurrentWnd();
	hbuf = GetCurrentBuf();
	if (hbuf == 0)
	        stop;   // empty buffer
	ln = GetBufLnCur(hbuf);
	ipos = GetWndSelIchFirst(hwnd);
	totalLn = GetBufLineCount(hbuf);
	text = GetBufLine(hbuf, ln); 
	if(GetBufSelText(hbuf) != "")   //选中文字
	{
	   ipos = GetWndSelIchLim(hwnd);
	   ln = GetWndSelLnLast(hwnd);
	   SetBufIns(hbuf, ln, ipos);
	   stop;
	}
	if(ipos == strlen(text)-1 && ln == totalLn-1) // 末行
	   stop;     
	if(ipos == strlen(text))
	{
	   SetBufIns(hBuf, ln+1, 0);
	}
	else
	{
	   SetBufIns(hBuf, ln, ipos+1);
	}
}
macro SuperCursorRight()
{
	moveRight();
	if(IsComplexCharacter()) // defined in SuperCursorLeft.em
	   moveRight();
}

macro IsShiftRightComplexCharacter()
{
	hwnd = GetCurrentWnd();
	hbuf = GetCurrentBuf();
	if (hbuf == 0)
	   return 0;
	selRec = GetWndSel(hwnd);
	pos = selRec.ichLim;
	ln = selRec.lnLast;
	text = GetBufLine(hbuf, ln);
	len = strlen(text);
	if(len == 0 || len < pos)
	   return 1;
	//Msg("@len@;@pos@;");
	if(pos > 0)
	{
	   i=pos;
	   count=0; 
	   while(AsciiFromChar(text[i-1]) >= 160)
	   { 
	    i = i - 1;
	    count = count+1;  
	    if(i == 0) 
	     break;   
	   }
	   if((count/2)*2==count|| count==0)
	    return 0;
	   else
	    return 1;
	}
	return 0;
}
macro shiftMoveRight()
{
	hwnd = GetCurrentWnd();
	hbuf = GetCurrentBuf();
	if (hbuf == 0)
	        stop;  
	ln = GetBufLnCur(hbuf);
	ipos = GetWndSelIchFirst(hwnd);
	totalLn = GetBufLineCount(hbuf);
	text = GetBufLine(hbuf, ln); 
	selRec = GetWndSel(hwnd);  
	curLen = GetBufLineLength(hbuf, selRec.lnLast);
	if(selRec.ichLim == curLen+1 || curLen == 0)
	{ 
	   if(selRec.lnLast == totalLn -1)
	    stop;
	   selRec.lnLast = selRec.lnLast + 1; 
	   selRec.ichLim = 1;
	   SetWndSel(hwnd, selRec);
	   if(IsShiftRightComplexCharacter())
	    shiftMoveRight();
	   stop;
	}
	selRec.ichLim = selRec.ichLim+1;
	SetWndSel(hwnd, selRec);
}
macro SuperShiftCursorRight()
{       
	if(IsComplexCharacter())
	   SuperCursorRight();
	shiftMoveRight();
	if(IsShiftRightComplexCharacter())
	   shiftMoveRight();
}

macro IsShiftLeftComplexCharacter()
{
	hwnd = GetCurrentWnd();
	hbuf = GetCurrentBuf();
	if (hbuf == 0)
	   return 0;
	selRec = GetWndSel(hwnd);
	pos = selRec.ichFirst;
	ln = selRec.lnFirst;
	text = GetBufLine(hbuf, ln);
	len = strlen(text);
	if(len == 0 || len < pos)
	   return 1;
	//Msg("@len@;@pos@;");
	if(pos > 0)
	{
	   i=pos;
	   count=0; 
	   while(AsciiFromChar(text[i-1]) >= 160)
	   { 
	    i = i - 1;
	    count = count+1;  
	    if(i == 0) 
	     break;   
	   }
	   if((count/2)*2==count|| count==0)
	    return 0;
	   else
	    return 1;
	}
	return 0;
}
macro shiftMoveLeft()
{
	hwnd = GetCurrentWnd();
	hbuf = GetCurrentBuf();
	if (hbuf == 0)
	        stop;  
	ln = GetBufLnCur(hbuf);
	ipos = GetWndSelIchFirst(hwnd);
	totalLn = GetBufLineCount(hbuf);
	text = GetBufLine(hbuf, ln); 
	selRec = GetWndSel(hwnd);  
	//curLen = GetBufLineLength(hbuf, selRec.lnFirst);
	//Msg("@curLen@;@selRec@");
	if(selRec.ichFirst == 0)
	{ 
	   if(selRec.lnFirst == 0)
	    stop;
	   selRec.lnFirst = selRec.lnFirst - 1;
	   selRec.ichFirst = GetBufLineLength(hbuf, selRec.lnFirst)-1;
	   SetWndSel(hwnd, selRec);
	   if(IsShiftLeftComplexCharacter())
	    shiftMoveLeft();
	   stop;
	}
	selRec.ichFirst = selRec.ichFirst-1;
	SetWndSel(hwnd, selRec);
}
macro SuperShiftCursorLeft()
{
	if(IsComplexCharacter())
	   SuperCursorLeft();
	shiftMoveLeft();
	if(IsShiftLeftComplexCharacter())
	   shiftMoveLeft();
}


