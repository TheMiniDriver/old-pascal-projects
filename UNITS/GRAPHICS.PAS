Unit Graphics;


Interface

Uses Crt,dos,graph,Mouse;


Procedure Brighten(Color_Value:Integer);
Procedure FadeDown(Color_Value:Integer);

Procedure video_mode (mode : Byte);
Procedure set_color (color, red, green, blue : Byte);
Procedure wait_4_refresh;

Procedure Load_BmP(X,Y:integer;file_name : string;var erro : integer);
Procedure SqrButton(X,Y,Length:Integer;Pressed:Boolean);
Procedure RectButton(X,Y,Length,Breadth:Integer;Pressed:Boolean);
Procedure Indent_Button(X,Y,Length,Breadth:Integer);


               {  *       *     * * *    * * *    }
               {    *   *      *  *  *   * * *    }
               {      *        *     *   *    *   }








Const
  vga_segment = $0A000;
  fade_Delay  = 0;
  vseg       = $A000;
      VIDEO     = $10;  { Video interrupt number                    }
      CRTC_ADDR	= $3d4; { Base port of the CRT Controller (color)   }
      SEQU_ADDR	= $3c4; { Base port of the Sequencer                }
      vgran     = 64;



Var
  lcv  : Integer;
  temp : Char;
  curbank,pixels:word;
    palette : palettetype;
    reg:registers;




Implementation


Procedure video_mode (mode : Byte); Assembler;
Asm
  mov  AH,00
  mov  AL,mode
  int  10h
end;

Procedure set_color (color, red, green, blue : Byte);
begin
  port[$3C8] := color;
  port[$3C9] := red;
  port[$3C9] := green;
  port[$3C9] := blue;
end;

Procedure wait_4_refresh; Assembler;
Label
  wait, retr;
Asm
  mov  DX,3DAh
 wait:  in   AL,DX
  test AL,08h
  jz   wait
 retr:  in   AL,DX
  test AL,08h
  jnz  retr
end;



Procedure Brighten(Color_value:Integer);  {Brightens the Screen}

begin
   {video_mode($13); }
      Repeat
       {wait_4_refresh;}
        set_color(0,Color_Value,Color_Value ,Color_Value);
        Inc(Color_Value);
        Delay(fade_Delay+100);
      Until (Color_Value)=63;
End;{Procedure Brighten}


Procedure FadeDown(Color_value:Integer);  {Fades Out the Screen}

Begin
     Repeat
     {wait_4_refresh;}
        set_color( 0, Color_Value,Color_Value,Color_Value );
        Delay(fade_Delay+100);
        Dec(Color_Value);
     Until Color_Value=0;
end;

  {video_mode(3);}

{  * * * * *            * * *      *             *      }
{  *         *        *      *       *         *        }
{  *          *      *                  *    *          }
{  *          *      *                    *             }
{  * * * * * *       *                  *    *          }
{  *                  *       *       *         *       }
{  *                     * * *      *             *     }

Procedure Load_BmP(X,Y:integer;file_name : string;var erro : integer);
  VAR
    header : array [1..27] of word;
    rgb_struct : array[0..255] of record
                                      b,g,r,cor : byte;
                                  end;
    rgb_triple : array[0..255] of record
                                      b,g,r : byte;
                                  end absolute rgb_struct;
    pal : array[0..255] of record
                                  red,green,blue : byte;
                            end;
    F : File;
    i,j : integer;
    locer : integer;
    XP,YP,lido,larg,larg1,alt,cores,bufsize,desloc,reloc,grupo : word;
    buf : array[1..10000] of byte;
    pic_point_1,pic_point_2 : byte;
    sign : array[1..2] of char absolute header;
    maxX,maxY : word;
  Begin
    maxX:=GetmaxX;
    maxY:=GetmaxY;
    assign(f, file_name);
     {$I-}
    reset (f, 1);
     {$I+}
    erro:=IoResult;
    if erro<>0 THEN exit;
     {$I-}
    blockread(f,header,18,lido);
    erro:=ioresult;
    if erro<>0 then
       if  sign<>'BM' THEN
	erro:=-100;
    IF erro=0 THEN
      BEGIN
	desloc:=header[8]-4;
	if desloc>36 then desloc:=36;
        blockread(f,header[10],desloc,lido);
	erro:=ioResult;
      END;
    if erro=0 THEN
      begin
        reloc:=ord(desloc<>8);
        larg:=header[10];
        alt:=header[11+reloc];
        cores := 1 shl header[13+2*reloc];
        if (alt > maxY) OR (larg>maxx) then
        erro :=-101;
      end;
    If erro = 0 THEN
      BEGIN
        if (X<0) oR (Y<0) THEN
          Begin
            X:=(maxX-larg) DIV 2;
	    Y:=(maxY-alt) DIV 2;
          End;
        blockread(f,rgb_struct,header[6]-18-desloc,lido);
        erro:=ioResult;
      END;
    IF erro = 0 THEN
      BEGIN
        if cores = 16 THEN
          begin
            larg1 := 8*(larg DIV 8) + 8*ord(larg MOD 8<>0);
            LARG1 := LARG1 div 2;
          end
         else
          begin
            larg1 := 4*(larg DIV 4) + 4*ord(larg MOD 4<>0);
          end;
        if reloc = 1
         THEN
          for i:= 0 to cores-1 do
            Begin
	      pal[i].red := rgb_struct[i].r DIV 4;
              pal[i].green := rgb_struct[i].g DIV 4;
	      pal[i].blue := rgb_struct[i].b DIV 4
            end
         else
          for i:=0 to cores-1 do
            Begin
		Pal[i].red := rgb_triple[i].r DIV 4;
		pal[i].green := rgb_triple[i].g DIV 4;
		pal[i].blue := rgb_triple[i].b DIV 4
            end;
        bufsize := larg1*(10000 DIV larg1);
        lido:=bufsize;
        While (lido=bufsize) AND (erro=0) do
          begin
	       blockread(f,buf,bufsize,lido);
               erro :=ioResult;
	       if erro = 0 Then
		IF Cores = 16
                 THEN
                  For j :=1 to lido DIV larg1 do
                    For i:=0 to larg-1 do
                      Begin
                        XP := X+i;
                        YP := Y+alt-j;
                        pic_point_1 := buf[(j-1)*larg1+ 1 + i DIV 2];
                        pic_point_2:=(pic_point_1 Shr 4)*((i+1) mOD 2) +
                          (pic_point_1 AND 15)*((i+2) MOD 2);
		        putpixel(XP,YP,pic_point_2);
                      End
		 ELSE
	          For j	:= 1 to lido DIV larg1 do
                    For i:=1 to larg do
                      Begin
		        XP:= x+(i-1);
		        YP:=Y+alt-j;
                        pic_point_1 := buf[(j-1)*larg1+i];
                        putpixel(XP,YP,pic_point_1);
                      end;
		Y := Y - lido DIV larg1;
          end; { while     }
        END; { erro =  0}
        close (f);
        {$I+}
        locer := ioresult;
	If erro = 0 ThEN erro := locer;
  END;

Procedure SqrButton;
{This procedure draws a square button at the point specified by the user}
Begin
   If Not(Pressed) Then
    Begin
    { Bar(x,y,(X+Length),(Y+Length));}
     Setcolor(63);
     Rectangle(x,y,(X+Length),(Y+Length));
     SetColor(56);
     Line(X,(Y+Length),(X+Length),(Y+Length));
     Line((X+Length),Y,(X+Length),(Y+Length));
     SetColor(0);
     SetLineStyle(0,0,1);
     Rectangle(x-2,y-2,(X+Length+2),(Y+Length+2));
     SetLineStyle(0,0,3);
    End
     Else
      Begin
       HideMouse;
        Setcolor(56);
        Rectangle(x,y,(X+Length),(Y+Length));
        SetColor(63);
        Line(X,(Y+Length),(X+Length),(Y+Length));
        Line((X+Length),Y,(X+Length),(Y+Length));
       Showmouse;
       Repeat Until Not(MouseClicked);
       HideMouse;
        Setcolor(63);
        Rectangle(x,y,(X+Length),(Y+Length));
        SetColor(56);
        Line(X,(Y+Length),(X+Length),(Y+Length));
        Line((X+Length),Y,(X+Length),(Y+Length));
        SetColor(0);
        SetLineStyle(0,0,1);
        Rectangle(x-2,y-2,(X+Length+2),(Y+Length+2));
        SetLineStyle(0,0,3);

       ShowMouse;

      End;

End;{SqrButton}

Procedure RectButton;
{This draws a rectangular button at the point specified by the user}
Begin
     If Not(Pressed) Then
    Begin

     Setcolor(63);
     Rectangle(x,y,(X+Length),(Y+Breadth));
     SetColor(56);
     Line(X,(Y+Breadth),(X+Length),(Y+Breadth));
     Line((X+Length),Y,(X+Length),(Y+Breadth));
    End
     Else
      Begin
        HideMouse;
        Setcolor(56);
        Rectangle(x,y,(X+Length),(Y+Breadth));
        SetColor(63);
        Line(X,(Y+Breadth),(X+Length),(Y+Breadth));
        Line((X+Length),Y,(X+Length),(Y+Breadth));
       ShowMouse;
       Repeat Until not(MouseClicked);
       HideMouse;
       Setcolor(63);
     Rectangle(x,y,(X+Length),(Y+Breadth));
     SetColor(56);
     Line(X,(Y+Breadth),(X+Length),(Y+Breadth));
     Line((X+Length),Y,(X+Length),(Y+Breadth));
      ShowMouse;

      End;
End;{Procedure RectButton}

Procedure Indent_Button;
{This procedure draws indented areas}
Begin
      HideMouse;
        Setcolor(56);
        Rectangle(x,y,(X+Length),(Y+Breadth));
        SetColor(63);
        Line(X,(Y+Breadth),(X+Length),(Y+Breadth));
        Line((X+Length),Y,(X+Length),(Y+Breadth));
       ShowMouse;
End;{Indent_Button}

END.






END OF UNIT GRAPHICS