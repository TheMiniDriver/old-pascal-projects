program Chess;
{Matric Computer project By Bradley Van Aardt .1999}

{$m 65520,0,655360}
uses Crt,Graph,Graphics,Mouse,Dos;

CONST
     Days : Array [0..6] of String[9] =
            ('Sun','Mon','Tue','Wed','Thur','Fri','Sat');
     {End of Days constant}
     Months : Array[1..12] of String[10] =
              ('January','February','March','April','May','June','July',
              'August','September','October','November','December');
     {End of Months Constant}

TYPE
    Pieces = Array[0..11] of Pointer;
    Check_Status = (None,RedKing,BlueKing);

    Details=Record
        BoardSetup:Array['1'..'8','A'..'H'] of Integer;
        Player:Boolean;
        Name:String
    End;{Details}

Var GD,GM,result,i:integer;
    Board1,Board2,White,Black:Pointer;
    Size,xm,xy:Word;

    Blue,Red:Pieces;
    Piece_Pos:Array['1'..'8','A'..'H'] of Integer;
    XPOS,YPOS:String[3];
    TempDate:String[20];
    TempTime:String[5];
    Column,Rows,TempRow,TempCol:Char;
    Click_One,Player1:Boolean;
    Data:File Of Details;
    SaveDetails:Details;

Function Date:String;
{This function returns the date in STRING form}
Var
   Year,Month,Day,DayName:Word;
   StrDay,StrYear:String[4];

Begin
     {This gets the date in Word form and then converts it to STRING form}
     GetDate(Year,Month,Day,DayName);
         Str(Year,StrYear);
         Str(Day,StrDay);
         Date:=((Days[DayName])+(', ')+(StrDay)+(' ')+(Months[Month])+
              (' ')+(StrYear));
End;{Function DATE}

Function Time:String;
{This function returns the current time in STRING form}
Var
   Hour,Minute,Second,HundSec:Word;
   StrHour,StrMin:String[2];

Begin
     {This gets the date in word form and then converts it to STRING}
      GetTime(Hour,Minute,Second,HundSec);
        Str(Hour,StrHour);
        Str(Minute,StrMin);
       If Length(StrMin)=1 then
         StrMin:='0'+StrMin;
        Time:=StrHour+(':')+StrMin;

End;

Procedure Display_Date;
{This procedure displays the date and time on the screen}
Begin
    If TempTime<>Time Then
     Begin
       SetColor(7);
       OutTextXY(590,6,TempTime);
       SetColor(0);
       OutTextXY(590,6,Time);
       TempTime:=Time;
     End;{If TempTime<>Time}

    If TempDate<>Date Then
     Begin
       SetColor(7);
       OutTextXY(435,6,TempDate);
       SetColor(0);
       OutTextXY(435,6,Date);
       TempDate:=Date;
     End;{If TempDate<>Date}


End;{Procedure Display date}

Function Black_OR_White(Col,Row:Char):Boolean;
{Determines if the given block is black or white.Returns True if White}

Var
   Error:Integer;
   Int_Col:Real;

Begin
     Val(Col,Int_Col,Error);



     If (Int_Col/2)=Trunc(Int_Col/2) then
       Case Row of
            'A','C','E','G': Black_OR_White:=False;
        Else Black_OR_White:=True;
       End

    Else
       Case Row of
            'A','C','E','G': Black_OR_White:=True;
        Else Black_OR_White:=False;
       End;




End;




Function Get_BlockY(Row:Char):Integer;
{Returns The top Y Value for any given row name A to H}

Begin
     Case Row of
        'A':Get_BlockY:=49;
        'B':Get_BlockY:=97;
        'C':Get_BlockY:=144;
        'D':Get_BlockY:=193;
        'E':Get_BlockY:=240;
        'F':Get_BlockY:=289;
        'G':Get_BlockY:=337;
        'H':Get_BlockY:=385;
       Else Get_blockY:=0;
   End;{CASE ROW}
End;{Function Get_BlockY}

Function Get_BlockX(Col:Char):Integer;
{Returns The Top Left X value for any given column Name 1 to 8}

Begin
     Case Col of
        '1':Get_BlockX:=102;
        '2':Get_BlockX:=155;
        '3':Get_BlockX:=207;
        '4':Get_BlockX:=260;
        '5':Get_BlockX:=312;
        '6':Get_BlockX:=365;
        '7':Get_BlockX:=417;
        '8':Get_BlockX:=470;
   End;{Case COL}
End;{Function Get_BlockX}




Procedure Place_Piece(Col,Row:Char;Piece_Type:Integer);
{This Procedure places the given piece type at the specified block}

Begin
   If (Get_BlockX(Col)>101) And (Get_BlockY(Row)>48) THEN
     Begin
      If Piece_Type<12 Then
           PutImage(Get_BlockX(Col),Get_BlockY(Row),Red[Piece_Type]^,0)
      Else PutImage(Get_BlockX(Col),Get_BlockY(Row),Blue[(Piece_Type)-12]^,0);

        Piece_Pos[Col,Row]:=Piece_Type;
     End;{IF}
End;{Procedure Place_Piece}

Function Check:Check_Status;
{This Function determines which colour is in check, if any}
Var Col,Row,Col2,Row2,Row3:Char; {These are Test variables}
    PieceFound:Boolean;
Begin
     Check:=None;
     PieceFound:=False;

     For Col:= '1' to '8' Do       {This Searches the board for the Kings}
      For Row:= 'A' to 'H' Do
       Begin

         If ((Piece_Pos[Col,Row]=0) Or (Piece_Pos[Col,Row]=1)) Then
          Begin {If the King Found is Red}

           {This will check if a pawn is about to take the king}

             Row2:=Row;
             Inc(row2);
            Case (Piece_Pos[Succ(Col),Row2])  Of
               22,23:Begin
                      Check:=RedKing;
                      EXIT;{If a pawn was found, then the procedure EXITS}
                    End;{Begin 22,23}
            End; {Case PiecePos of Pawn}

            Case (Piece_Pos[Pred(Col),Row2])  Of
               22,23:Begin
                      Check:=RedKing;
                      EXIT;{If a pawn was found, then the procedure EXITS}
                    End;{Begin 22,23}
            End; {Case PiecePos of Pawn}

             Row2:=Row;
            Repeat                               {This checks if the king   }
             If (Row2<'H') Then Inc(Row2);
             If (Piece_Pos[Col,Row2]<>100)    { is clear from enemy      }
              Then
              Begin                             { pieces in the same Column}
                PieceFound:=True;
               Case (Piece_Pos[Col,Row2]) of
                14,15,18,19:Begin                {If a piece capabale of }
                              Check:=RedKing;    { of taking the king in }
                              EXIT;              {the column is found, the}
                            End;{14,15,18,19}    {king is put in check }
               End;{Case}
              End;{If Piece_Pos<>100}
              { If (Row2<'H') Then Inc(Row2);}

            Until ((PieceFound) Or (Row2='H'));


                Row2:=Row;
               PieceFound:=False;
               {If (Row2>'A') Then Dec(Row2);}

            Repeat                               {This checks if the king   }
             If (Row2>'A') Then Dec(Row2);
             If (Piece_Pos[Col,Row2]<>100)       { is clear from enemy      }
                 Then
              Begin                              { pieces in the same Column}
                PieceFound:=True;
               Case (Piece_Pos[Col,Row2]) of
                14,15,18,19:Begin                {If a piece capabale of }
                              Check:=RedKing;    { of taking the king in }
                              EXIT;              {the column is found, the}
                            End;{14,15,18,19}    {king is put in check }
               End;{Case}
              End;{If Piece_Pos<>100}


            Until ((PieceFound) Or (Row2='A'));

            Col2:=Col;
            PieceFound:=False;


          Repeat                               {This checks if the king   }
             If (Col2<'8') Then Inc(Col2);

             If (Piece_Pos[Col2,Row]<>100)    { is clear from enemy      }
              Then
              Begin                             { pieces in the same Row}
                PieceFound:=True;
               Case (Piece_Pos[Col2,Row]) of
                14,15,18,19:Begin                {If a piece capabale of }
                              Check:=RedKing;    { of taking the king in }
                              EXIT;              {the Row is found, the  }
                            End;{14,15,18,19}    {king is put in check   }
               End;{Case}
              End;{If Piece_Pos<>100}


            Until ((PieceFound) Or (Col2='8'));


                Col2:=Col;
               PieceFound:=False;
               If (Col2>'1') Then Dec(Col2);

            Repeat                               {This checks if the king   }
              If (Col2>'1') Then Dec(Col2);
             If (Piece_Pos[Col2,Row]<>100)       { is clear from enemy      }
                 Then
              Begin                              { pieces in the same Row}
                PieceFound:=True;
               Case (Piece_Pos[Col2,Row]) of
                14,15,18,19:Begin                {If a piece capabale of }
                              Check:=RedKing;    { of taking the king in }
                              EXIT;              {the Row is found, the}
                            End;{14,15,18,19}    {king is put in check }
               End;{Case}
              End;{If Piece_Pos<>100}


            Until ((PieceFound) Or (Col2='1'));

        {This section will check if the king is in check from a piece
        Diagonally}
          Row2:=Row;
          Col2:=Col;
          PieceFound:=False;


         Repeat
          If ((Row2<'H') And (Col2<'8')) Then Inc(Row2);
           If ((Col2<'8') And (Row2<='H')) Then Inc(Col2);

           If (Piece_Pos[Col2,Row2]<>100)
                 Then
              Begin
                PieceFound:=True;
               Case (Piece_Pos[Col2,Row2]) of
                14,15,20,21:Begin                {If a piece capabale of }
                              Check:=RedKing;    { of taking the king in }
                              EXIT;              {the Line is found, the}
                            End;{14,15,20,21}    {king is put in check }
               End;{Case}
              End;{If Piece_Pos<>100}

         Until ((PieceFound) Or (Col2='8') Or (Row2='H'));

          Row2:=Row;
          Col2:=Col;
          PieceFound:=False;


         Repeat
          If ((Row2>('A')) And (Col2<'8')) Then Dec(Row2);
           If ((Col2<'8') And (Row2>=('A'))) Then Inc(Col2);

           If (Piece_Pos[Col2,Row2]<>100)
                 Then
              Begin
                PieceFound:=True;
               Case (Piece_Pos[Col2,Row2]) of
                14,15,20,21:Begin                {If a piece capabale of }
                              Check:=RedKing;    { of taking the king in }
                              EXIT;              {the Line is found, the}
                            End;{14,15,20,21}    {king is put in check }
               End;{Case}
              End;{If Piece_Pos<>100}

         Until ((PieceFound) Or (Col2='8') Or (Row2='A'));


          Row2:=Row;
          Col2:=Col;
          PieceFound:=False;


         Repeat
          If ((Row2>'A') And (Col2>'1')) Then Dec(Row2);
           If ((Row2>='A') And (Col2>'1')) Then Dec(Col2);

           If (Piece_Pos[Col2,Row2]<>100)
                 Then
              Begin
                PieceFound:=True;
               Case (Piece_Pos[Col2,Row2]) of
                14,15,20,21:Begin                {If a piece capabale of }
                              Check:=RedKing;    { of taking the king in }
                              EXIT;              {the Line is found, the}
                            End;{14,15,20,21}    {king is put in check }
               End;{Case}
              End;{If Piece_Pos<>100}
           Until ((PieceFound) Or (Col2='1') Or (Row2='A'));

          Row2:=Row;
          Col2:=Col;
          PieceFound:=False;


         Repeat
          If ((Row2<'H') And (Col2>'1')) Then Inc(Row2);
           If ((Row2<='H') And (Col2>'1')) Then Dec(Col2);

           If (Piece_Pos[Col2,Row2]<>100)
                 Then
              Begin
                PieceFound:=True;
               Case (Piece_Pos[Col2,Row2]) of
                14,15,20,21:Begin                {If a piece capabale of }
                              Check:=RedKing;    { of taking the king in }
                              EXIT;              {the Line is found, the}
                            End;{14,15,20,21}    {king is put in check }
               End;{Case}
              End;{If Piece_Pos<>100}

         Until ((PieceFound) Or (Col2='1') Or (Row2='H'));

     {This will check if the king is in check with a knight}
         Row2:=Row;
         Col2:=Col;
     If (Row2<'H') Then  {If the King is not at the bottom of the board}
      Begin

          Inc(Row2);
         If (Col<'7') Then
           Begin
            Inc(Col2,2);
            Case (Piece_Pos[Col2,Row2]) Of
                16,17:Begin
                        Check:=RedKing;
                        Exit;
                      End;{16,17..}
            End;{Case Piece_Pos of Knights}
           End;{If Col<7}

           Col2:=Col;
         If (Col>'2') Then
           Begin
            Dec(Col2,2);
            Case (Piece_Pos[Col2,Row2]) Of
                16,17:Begin
                        Check:=RedKing;
                        Exit;
                      End;{16,17..}
            End;{Case Piece_Pos of Knights}
           End;{If Col>2}

          Col2:=Col;
        If (Row<'G') Then
          Begin
           Inc(Row2);
            If (Col<'8') Then
           Begin
            Inc(Col2);
            Case (Piece_Pos[Col2,Row2]) Of
                16,17:Begin
                        Check:=RedKing;
                        Exit;
                      End;{16,17..}
            End;{Case Piece_Pos of Knights}
           End;{If Col<7}

           Col2:=Col;
         If (Col>'1') Then
           Begin
            Dec(Col2);
            Case (Piece_Pos[Col2,Row2]) Of
                16,17:Begin
                        Check:=RedKing;
                        Exit;
                      End;{16,17..}
            End;{Case Piece_Pos of Knights}
           End;{If Col>2}
       End;{If Row<G}
      End;{If Row <H}

       Row2:=Row;
       Col2:=Col;
     If (Row2>'A') Then  {If the King is not at the top of the board}
      Begin

          Dec(Row2);
         If (Col<'7') Then
           Begin
            Inc(Col2,2);
            Case (Piece_Pos[Col2,Row2]) Of
                16,17:Begin
                        Check:=RedKing;
                        Exit;
                      End;{16,17..}
            End;{Case Piece_Pos of Knights}
           End;{If Col<7}

           Col2:=Col;
         If (Col>'2') Then
           Begin
            Dec(Col2,2);
            Case (Piece_Pos[Col2,Row2]) Of
                16,17:Begin
                        Check:=RedKing;
                        Exit;
                      End;{16,17..}
            End;{Case Piece_Pos of Knights}
           End;{If Col>2}

          Col2:=Col;
        If (Row>'B') Then
          Begin
           Dec(Row2);
            If (Col<'8') Then
           Begin
            Inc(Col2);
            Case (Piece_Pos[Col2,Row2]) Of
                16,17:Begin
                        Check:=RedKing;
                        Exit;
                      End;{16,17..}
            End;{Case Piece_Pos of Knights}
           End;{If Col<7}

           Col2:=Col;
         If (Col>'1') Then
           Begin
            Dec(Col2);
            Case (Piece_Pos[Col2,Row2]) Of
                16,17:Begin
                        Check:=RedKing;
                        Exit;
                      End;{16,17..}
            End;{Case Piece_Pos of Knights}
           End;{If Col>2}
       End;{If Row>B}
      End;{If Row>A}


      End;{If Piece_Pos=0 or 1 (Red King Found)}

     If ((Piece_Pos[Col,Row]=12) Or (Piece_Pos[Col,Row]=13)) Then
          Begin {If the King Found is Blue}

           {This will check if a pawn is about to take the king}

             Row2:=Row;
             Dec(row2);
            Case (Piece_Pos[Succ(Col),Row2])  Of
               10,11:Begin
                      Check:=BlueKing;
                      EXIT;{If a pawn was found, then the procedure EXITS}
                    End;{Begin 10,11}
            End; {Case PiecePos of Pawn}

            Case (Piece_Pos[Pred(Col),Row2])  Of
               10,11:Begin
                      Check:=BlueKing;
                      EXIT;{If a pawn was found, then the procedure EXITS}
                    End;{Begin 10,11}
            End; {Case PiecePos of Pawn}

             Row2:=Row;
            Repeat                               {This checks if the king   }
             If (Row2<'H') Then Inc(Row2);
             If (Piece_Pos[Col,Row2]<>100)    { is clear from enemy      }
              Then
              Begin                             { pieces in the same Column}
                PieceFound:=True;
               Case (Piece_Pos[Col,Row2]) of
                2,3,6,7:Begin                {If a piece capabale of }
                              Check:=BlueKing;    { of taking the king in }
                              EXIT;              {the column is found, the}
                            End;{2,3,6,7}    {king is put in check }
               End;{Case}
              End;{If Piece_Pos<>100}


            Until ((PieceFound) Or (Row2='H'));


                Row2:=Row;
               PieceFound:=False;


            Repeat                               {This checks if the king   }
             If (Row2>'A') Then Dec(Row2);
             If (Piece_Pos[Col,Row2]<>100)       { is clear from enemy      }
                 Then
              Begin                              { pieces in the same Column}
                PieceFound:=True;
               Case (Piece_Pos[Col,Row2]) of
                2,3,6,7:Begin                {If a piece capabale of }
                              Check:=BlueKing;    { of taking the king in }
                              EXIT;              {the column is found, the}
                            End;{2,3,6,7}    {king is put in check }
               End;{Case}
              End;{If Piece_Pos<>100}


            Until ((PieceFound) Or (Row2='A'));

            Col2:=Col;
            PieceFound:=False;


          Repeat                               {This checks if the king   }
             If (Col2<'8') Then Inc(Col2);

             If (Piece_Pos[Col2,Row]<>100)    { is clear from enemy      }
              Then
              Begin                             { pieces in the same Row}
                PieceFound:=True;
               Case (Piece_Pos[Col2,Row]) of
                2,3,6,7:Begin                {If a piece capabale of }
                              Check:=BlueKing;    { of taking the king in }
                              EXIT;              {the Row is found, the  }
                            End;{2,3,6,7}    {king is put in check   }
               End;{Case}
              End;{If Piece_Pos<>100}


            Until ((PieceFound) Or (Col2='8'));


                Col2:=Col;
               PieceFound:=False;
               If (Col2>'1') Then Dec(Col2);

            Repeat                               {This checks if the king   }
              If (Col2>'1') Then Dec(Col2);
             If (Piece_Pos[Col2,Row]<>100)       { is clear from enemy      }
                 Then
              Begin                              { pieces in the same Row}
                PieceFound:=True;
               Case (Piece_Pos[Col2,Row]) of
                2,3,6,7:Begin                {If a piece capabale of }
                              Check:=BlueKing;    { of taking the king in }
                              EXIT;              {the Row is found, the}
                            End;{2,3,6,7}    {king is put in check }
               End;{Case}
              End;{If Piece_Pos<>100}


            Until ((PieceFound) Or (Col2='1'));

        {This section will check if the king is in check from a piece
        Diagonally}
          Row2:=Row;
          Col2:=Col;
          PieceFound:=False;


         Repeat
          If ((Row2<'H') And (Col2<'8')) Then Inc(Row2);
           If ((Row2<='H') And (Col2<'8')) Then Inc(Col2);

           If (Piece_Pos[Col2,Row2]<>100)
                 Then
              Begin
                PieceFound:=True;
               Case (Piece_Pos[Col2,Row2]) of
                2,3,8,9:Begin                {If a piece capabale of }
                              Check:=BlueKing;    { of taking the king in }
                              EXIT;              {the Line is found, the}
                            End;{2,3,8,9}    {king is put in check }
               End;{Case}
              End;{If Piece_Pos<>100}

         Until ((PieceFound) Or (Col2='8') Or (Row2='H'));

          Row2:=Row;
          Col2:=Col;
          PieceFound:=False;


         Repeat
          If ((Row2>'A') And (Col2<'8')) Then Dec(Row2);
           If ((Row2>='A') And (Col2<'8')) Then Inc(Col2);

           If (Piece_Pos[Col2,Row2]<>100)
                 Then
              Begin
                PieceFound:=True;
               Case (Piece_Pos[Col2,Row2]) of
                2,3,8,9:Begin                {If a piece capabale of }
                              Check:=BlueKing;    { of taking the king in }
                              EXIT;              {the Line is found, the}
                            End;{2,3,8,9}    {king is put in check }
               End;{Case}
              End;{If Piece_Pos<>100}

         Until ((PieceFound) Or (Col2='8') Or (Row2='A'));


          Row2:=Row;
          Col2:=Col;
          PieceFound:=False;


         Repeat
          If ((Row2>'A') And (Col2>'1')) Then Dec(Row2);
           If ((Row2>='A') And (Col2>'1')) Then Dec(Col2);

           If (Piece_Pos[Col2,Row2]<>100)
                 Then
              Begin
                PieceFound:=True;
               Case (Piece_Pos[Col2,Row2]) of
                2,3,8,9:Begin                {If a piece capabale of }
                              Check:=BlueKing;    { of taking the king in }
                              EXIT;              {the Line is found, the}
                            End;{2,3,8,9}    {king is put in check }
               End;{Case}
              End;{If Piece_Pos<>100}
           Until ((PieceFound) Or (Col2='1') Or (Row2='A'));

          Row2:=Row;
          Col2:=Col;
          PieceFound:=False;


         Repeat
          If ((Row2<'H') And (Col2>'1')) Then Inc(Row2);
           If ((Row2<='H') And (Col2>'1')) Then Dec(Col2);

           If (Piece_Pos[Col2,Row2]<>100)
                 Then
              Begin
                PieceFound:=True;
               Case (Piece_Pos[Col2,Row2]) of
                2,3,8,9:Begin                {If a piece capabale of }
                              Check:=BlueKing;    { of taking the king in }
                              EXIT;              {the Line is found, the}
                            End;{2,3,8,9}    {king is put in check }
               End;{Case}
              End;{If Piece_Pos<>100}

         Until ((PieceFound) Or (Col2='1') Or (Row2='H'));

     {This will check if the king is in check with a knight}
         Row2:=Row;
         Col2:=Col;
     If (Row2<'H') Then  {If the King is not at the bottom of the board}
      Begin

          Inc(Row2);
         If (Col<'7') Then
           Begin
            Inc(Col2,2);
            Case (Piece_Pos[Col2,Row2]) Of
                4,5:Begin
                        Check:=BlueKing;
                        Exit;
                      End;{4,5..}
            End;{Case Piece_Pos of Knights}
           End;{If Col<7}

           Col2:=Col;
         If (Col>'2') Then
           Begin
            Dec(Col2,2);
            Case (Piece_Pos[Col2,Row2]) Of
                4,5:Begin
                        Check:=BlueKing;
                        Exit;
                      End;{4,5..}
            End;{Case Piece_Pos of Knights}
           End;{If Col>2}

          Col2:=Col;
        If (Row<'G') Then
          Begin
           Inc(Row2);
            If (Col<'8') Then
           Begin
            Inc(Col2);
            Case (Piece_Pos[Col2,Row2]) Of
                4,5:Begin
                        Check:=BlueKing;
                        Exit;
                      End;{4,5..}
            End;{Case Piece_Pos of Knights}
           End;{If Col<7}

           Col2:=Col;
         If (Col>'1') Then
           Begin
            Dec(Col2);
            Case (Piece_Pos[Col2,Row2]) Of
                4,5:Begin
                        Check:=BlueKing;
                        Exit;
                      End;{4,5..}
            End;{Case Piece_Pos of Knights}
           End;{If Col>2}
       End;{If Row<G}
      End;{If Row <H}

       Row2:=Row;
       Col2:=Col;
     If (Row2>'A') Then  {If the King is not at the top of the board}
      Begin

          Dec(Row2);
         If (Col<'7') Then
           Begin
            Inc(Col2,2);
            Case (Piece_Pos[Col2,Row2]) Of
                4,5:Begin
                        Check:=BlueKing;
                        Exit;
                      End;{4,5..}
            End;{Case Piece_Pos of Knights}
           End;{If Col<7}

           Col2:=Col;
         If (Col>'2') Then
           Begin
            Dec(Col2,2);
            Case (Piece_Pos[Col2,Row2]) Of
                4,5:Begin
                        Check:=BlueKing;
                        Exit;
                      End;{4,5..}
            End;{Case Piece_Pos of Knights}
           End;{If Col>2}

          Col2:=Col;
        If (Row>'B') Then
          Begin
           Dec(Row2);
            If (Col<'8') Then
           Begin
            Inc(Col2);
            Case (Piece_Pos[Col2,Row2]) Of
                4,5:Begin
                        Check:=BlueKing;
                        Exit;
                      End;{4,5..}
            End;{Case Piece_Pos of Knights}
           End;{If Col<7}

           Col2:=Col;
         If (Col>'1') Then
           Begin
            Dec(Col2);
            Case (Piece_Pos[Col2,Row2]) Of
                4,5:Begin
                        Check:=BlueKing;
                        Exit;
                      End;{4,5..}
            End;{Case Piece_Pos of Knights}
           End;{If Col>2}
       End;{If Row>B}
      End;{If Row>A}


      End;{If Piece_Pos=12 or 13 (Blue King Found)}






   End;{For}

End;{Function Check}

Function ValidMove(Col,Row:Char):Boolean;
{This Determines if the move being performed is valid or not}
Var Check:Char;{This is a test variable}
    Counter:Integer;

Begin
     ValidMove:=False;

     Case Piece_Pos[TempCol,TempRow] Of

          0,1,12,13:{This works out the valid moves for the Kings}
       Begin

         {THIS DETERMINES IF THE KING IS BEING MOVED MORE THAN 1 BLOCK AT
          A TIME. IF TRUE, THE PROCEDURE EXITS.}
          If (Col>Succ(TempCol)) Or (Col<Pred(TempCol)) Then EXIT;
          If (Row>Succ(TempRow)) Or (Row<Pred(TempRow)) Then EXIT;

          ValidMove:=True;
       End;
       {End of the KING CASE OF}

          2,3,14,15:{This works out the valid moves for the Queens}
      Begin

  {This section works out if the queen is moving horizontally or vertically}
        If (TempCol=Col) then
            Begin
        {This checks if the Queen is being moved from the top to the bottom
          of the board}
             If TempRow<row then
              For Check:= TempRow to Row DO
               Begin
                 If ((Check<>TempRow) And (Check<>Row)) Then
                 If (Piece_Pos[TempCol,Check]<100) then EXIT;
               End;{FOR}
        {This checks if the Queen is being moved from the bottom to the top
         of the board}
             If TempRow>row then
              For Check:= TempRow downto Row DO
               Begin
                 If ((Check<>TempRow) And (Check<>Row)) Then
                 If (Piece_Pos[TempCol,Check]<100) then EXIT;
               End;{FOR}
             validMove:=true;
         End;{If TempCol=col}

        If TempRow=Row then
       Begin
        {This checks if the Queen is being moved from the Left to the Right
          of the board}
             If TempCol<Col then
              For Check:= TempCol to Col DO
               Begin
                 If ((Check<>TempCol) And (Check<>Col)) Then
                 If (Piece_Pos[Check,TempRow]<100) then EXIT;
               End;{FOR}
        {This checks if the Queen is being moved from the Right to the Left
         of the board}
             If TempCol>Col then
              For Check:= TempCol downto Col DO
               Begin
                 If ((Check<>TempCol) And (Check<>Col)) Then
                 If (Piece_Pos[Check,TempRow]<100) then EXIT;
               End;{FOR}
             validMove:=true;
         End;{If TempRow=Row}

 {This section deals with the queen moving diagonally across the board}
          Check:=TempCol;
          Counter:=0;
             {If the Queen is being moved horizontally or vertically
             then EXIT as this possibility has been dealt with above}
           If (TempRow=Row) Or (TempCol=Col) Then EXIT;

           Repeat                { This Counts How many columns the Queen}
             Inc(Counter);       { has been moved over}
            If TempCol<Col Then
             Inc(Check)
            Else
             Dec(Check);

           Until (Check=Col);


           Check:=TempRow;            {This checks if the number of rows }
            If TempRow<Row Then       { moved across corresponds to the  }
             Inc(Check,Counter)       { number of columns moved across   }
            Else                      { i.e. If the piece is being moved }
             Dec(Check,Counter);      { diagonally.                      }

           If Check<> Row Then EXIT;


            For I:= 1 to (Counter-1) DO           {This Checks if anything}
             Begin                                { is in the path of the }
              If (TempCol<Col) Then Dec(Col)      { Queen. If true the   }
               Else Inc(Col);                     { procedure EXITS.      }

              If (TempRow<Row) Then Dec(Row)
               Else Inc(Row);
              If Piece_Pos[Col,Row]<100 then EXIT;
            End;

          ValidMove:=True;
      End;
      {End of the Queen Case of}


          4,5,16,17:{This works out the valid moves for the Knights}
      Begin{Knights}

        {This puts the Column variable into another variable so it can
          be modified and tested for validity}
          Check:=TempCol;
           Dec(Check,2);

        {This checks if the Knight is being moved across columns and up or
         down a row}
           If (Check=Col) Then
              If (Pred(TempRow)=Row) OR (Succ(TempRow)=Row) Then
               VALIDMOVE:=TRUE;

            Inc(Check,4);

           If (Check=Col) Then
              If (Pred(TempRow)=Row) OR (Succ(TempRow)=Row) Then
               VALIDMOVE:=TRUE;

           {This puts the Row variable into another variable so it can
          be modified and tested for validity}
             Check:=TempRow;
             Dec(Check,2);

         {This checks if the the knight is being moved across rows and
          one block left or right on the board}

             If (Check=Row) Then
              If (Pred(TempCol)=Col) OR (Succ(TempCol)=Col) Then
               VALIDMOVE:=TRUE;

            Inc(Check,4);

           If (Check=Row) Then
              If (Pred(TempCol)=Col) OR (Succ(TempCol)=Col) Then
               VALIDMOVE:=TRUE;

          {If the move has not complied with any of the above conditions,
           then the Case ends without the ValidMove function being set to
           TRUE}

      End;{Knights}



          6,7,18,19:{This works out the valid moves for the Rooks}
      Begin

           If (TempCol=Col) then
            Begin

        {This checks if the rook is being moved from the top to the bottom
          of the board}
             If TempRow<row then
              For Check:= TempRow to Row DO
               Begin
                 If ((Check<>TempRow) And (Check<>Row)) Then
                 If (Piece_Pos[TempCol,Check]<100) then EXIT;
               End;{FOR}
        {This checks if the rook is being moved from the bottom to the top
         of the board}
             If TempRow>row then
              For Check:= TempRow downto Row DO
               Begin
                 If ((Check<>TempRow) And (Check<>Row)) Then
                 If (Piece_Pos[TempCol,Check]<100) then EXIT;
               End;{FOR}
             validMove:=true;
         End;{If TempCol=col}

        If TempRow=Row then
       Begin
        {This checks if the rook is being moved from the Left to the Right
          of the board}
             If TempCol<Col then
              For Check:= TempCol to Col DO
               Begin
                 If ((Check<>TempCol) And (Check<>Col)) Then
                 If (Piece_Pos[Check,TempRow]<100) then EXIT;
               End;{FOR}
        {This checks if the rook is being moved from the Right to the Left
         of the board}
             If TempCol>Col then
              For Check:= TempCol downto Col DO
               Begin
                 If ((Check<>TempCol) And (Check<>Col)) Then
                 If (Piece_Pos[Check,TempRow]<100) then EXIT;
               End;{FOR}
             validMove:=true;
         End;{If TempRow=Row}


      End;{Case Of Rook}

         8,9,20,21:{This works out the valid moves for the Bishops}
      Begin
          Check:=TempCol;
          Counter:=0;
             {If the Bishop is being horizontally or vertically then EXIT}
           If (TempRow=Row) Or (TempCol=Col) Then EXIT;

           Repeat                { This Counts How many columns the bishop}
             Inc(Counter);       { has been moved over}
            If TempCol<Col Then
             Inc(Check)
            Else
             Dec(Check);

           Until (Check=Col);


           Check:=TempRow;            {This checks if the number of rows }
            If TempRow<Row Then       { moved across corresponds to the  }
             Inc(Check,Counter)       { number of columns moved across   }
            Else                      { i.e. If the piece is being moved }
             Dec(Check,Counter);      { diagonally.                      }

           If Check<> Row Then EXIT;


            For I:= 1 to (Counter-1) DO           {This Checks if anything}
             Begin                                { is in the path of the }
              If (TempCol<Col) Then Dec(Col)      { Bishop. If true the   }
               Else Inc(Col);                     { procedure EXITS.      }

              If (TempRow<Row) Then Dec(Row)
               Else Inc(Row);
              If Piece_Pos[Col,Row]<100 then EXIT;
            End;



          ValidMove:=True;

      End;{Case Of BISHOP}

         10,11,22,23:{This works out the valid moves for the Pawns}
      Begin

        {This works out the Valid moves for the Red pawns}
          If (Piece_Pos[TempCol,TempRow]<12) then
           Begin
            {This Checks if the pawn is being moved one block ahead}
             If ((Succ(TempRow)=Row) And (TempCol=Col) And
              (Piece_Pos[Col,Row]=100)) then ValidMove:=True;

            {This checks if the pawn is being moved 2 blocks ahead on
             it's first move}
             If ((TempRow='B') And (Succ(TempRow)=Pred(Row)) And
             (TempCol=Col) And (Piece_Pos[Col,Row]=100)) then
               ValidMove:=True;

            {This checks if the pawn is being moved diagonally across 1
             block and is taking a piece}
             If (Succ(TempRow)=Row) And ((Succ(TempCol)=Col) OR
              (Pred(TempCol)=Col)) And (Piece_Pos[Col,Row]<>100) Then
               ValidMove:=True;

           End;{Red Pawns (Piece_Pos<12)}


          {This works out the Valid moves for the Blue pawns}
          If (Piece_Pos[TempCol,TempRow]>21) then
           Begin
            {This Checks if the pawn is being moved one block ahead}
             If ((Pred(TempRow)=Row) And (TempCol=Col) And
              (Piece_Pos[Col,Row]=100)) then ValidMove:=True;

            {This checks if the pawn is being moved 2 blocks ahead on
             it's first move}
             If ((TempRow='G') And (Pred(TempRow)=Succ(Row)) And
             (TempCol=Col) And (Piece_Pos[Col,Row]=100)) then
               ValidMove:=True;

            {This checks if the pawn is being moved diagonally across 1
             block and is taking a piece}
             If (Pred(TempRow)=Row) And ((Pred(TempCol)=Col) OR
              (Succ(TempCol)=Col)) And (Piece_Pos[Col,Row]<>100) Then
               ValidMove:=True;

           End;{Blue Pawns (Piece_Pos>21)}



      End;{Case Of Pawns}





     End;{CASE}
END;{FUNCTION VALIDMOVE}



Procedure Click(col,row:Char);
{This Procedure is called when the mouse is clicked}
Var X,Y,TempName:Integer;
    Done:Boolean;
Begin

    Done:=False;
   If (Not(Click_One)) and (Row<>' ') And (Col<>' ')then
    Begin

      If Piece_Pos[Col,Row]>23 then EXIT;
      If Player1 AND (Piece_Pos[Col,Row]>11) Then EXIT;
      If (NOT(Player1)) AND (Piece_Pos[Col,Row]<12) Then EXIT;

      X:=Get_BlockX(Col);
      Y:=Get_BlockY(Row);
     SetColor(60);
     SetLineStyle(0,0,3);
     HideMouse;
     Rectangle(X+3,Y+1,(X+48),(Y+44));
     SetLineStyle(0,0,3);
     ShowMouse;
     Click_One:=True;
     TempRow:=Row;
     TempCol:=Col;
     Repeat
     Display_Date;
     until Not(Mouseclicked);
     exit;
    End;



  If (Click_One) and (Row<>' ') And (Col<>' ') {And {MouseClicked} then
    Begin



     If (Col=TempCol) AND (Row=TempRow) then
       Begin
        HideMouse;
        Place_Piece(Col,Row,(Piece_Pos[TempCol,TempRow]));
        ShowMouse;
        Click_One:=False;
        Repeat until Not(Mouseclicked);
       End;{(IF COL=TempCol). This Checks if a piece has been double-Clicked
            If True, The original piece is replaced to erase the selection
            Block}


     If ((Piece_Pos[TempCol,TempRow]<12) AND (Piece_Pos[Col,Row]<12))
       OR ((Piece_Pos[TempCol,TempRow]>11)
        AND ((Piece_Pos[Col,Row]>11) AND (Piece_Pos[Col,Row]<24)))
        Then
            EXIT; {Checks If the Piece Being moved is being placed on
                   another piece of the same colour
                  Red's pieces are numbers 0..11 and Blue's are 12..23
                  If True, the program will EXIT the procedure}

      {THIS DETERMINES IF THE PIECE IS TRYING TO TAKE THE OPPOSITION KING}
          Case Piece_Pos[Col,Row] OF
             0,1,12,13:EXIT;
          END;{CASE}



    If Not(ValidMove(Col,Row)) Then EXIT; {This calls a procedure to see
                                           if the moved being performed is
                                           valid or not}

    {This tests if the proposed move will put the side in check}

     TempName:=Piece_Pos[Col,Row];
     Piece_Pos[Col,Row]:=Piece_Pos[TempCol,TempRow];
     Piece_Pos[TempCol,TempRow]:=100;
     If Piece_Pos[Col,Row]<12 Then
      Begin
       If Check=RedKing Then
        Begin
          Piece_Pos[TempCol,TempRow]:=Piece_Pos[Col,Row];
          Piece_Pos[Col,Row]:=TempName;
          EXIT;
        End;{If Check=Red}
      End;{If PiecePos <12}

     If Piece_Pos[Col,Row]>12 Then
      Begin
       If Check=BlueKing Then
        Begin
          Piece_Pos[TempCol,TempRow]:=Piece_Pos[Col,Row];
          Piece_Pos[Col,Row]:=TempName;
          EXIT;
        End;{If Check=Blue}
      End;{If PiecePos >12}
                 {This sets the array back to it's original settings}

      Piece_Pos[TempCol,TempRow]:=Piece_Pos[Col,Row];
      Piece_Pos[Col,Row]:=TempName;


    Case Piece_Pos[TempCol,TempRow] of
      {This will check if a pawn has reached the end of the board       }
      { If it has, it will be replaced by a Queen.                      }

         10,11: {This Checks if a Red Pawn has made it across}
            Begin

             If (Row='H') And (Piece_Pos[TempCol,TempRow]=10) Then
               Piece_Pos[TempCol,TempRow]:=3;

             If (Row='H') And (Piece_Pos[TempCol,TempRow]=11) Then
               Piece_Pos[TempCol,TempRow]:=2;
            End;{10,11}

         22,23: {This checks if a Blue pawn has made it across}
            Begin
             If (Row='A') And (Piece_Pos[TempCol,TempRow]=22) Then
               Piece_Pos[TempCol,TempRow]:=15;

             If (Row='A') And (Piece_Pos[TempCol,TempRow]=23) Then
               Piece_Pos[TempCol,TempRow]:=14;

            End;{22,23}

       End;{Case Piece_Pos of 10,11,..(If pawn has made it across to the}
           {other side}



   If (Col<>TempCol) Or (Row<>TempRow) Then
    Begin
       HideMouse;

      If Black_Or_White(TempCol,TempRow)=Black_Or_White(Col,Row)
        Then
        Place_Piece(Col,Row,(Piece_Pos[TempCol,TempRow]))

      Else

      If Black_OR_White(Col,Row)=True Then
       Begin

        If (Piece_Pos[TempCol,TempRow]>19) Then
            Place_Piece(Col,Row,(Piece_Pos[TempCol,TempRow]-1))
         Else
        If (Piece_Pos[TempCol,TempRow]>7) And (Piece_Pos[TempCol,TempRow]<12)
           Then
            Place_Piece(Col,Row,(Piece_Pos[TempCol,TempRow]-1))
         Else
            Place_Piece(Col,Row,(Piece_Pos[TempCol,TempRow]+1));

       End{If Black Or White(col,Row)=True}

      Else
        Begin
              If (Piece_Pos[TempCol,TempRow]>19) Then
            Place_Piece(Col,Row,(Piece_Pos[TempCol,TempRow]+1))
         Else
        If (Piece_Pos[TempCol,TempRow]>7) And (Piece_Pos[TempCol,TempRow]<12)
           Then
            Place_Piece(Col,Row,(Piece_Pos[TempCol,TempRow]+1))
         Else
            Place_Piece(Col,Row,(Piece_Pos[TempCol,TempRow]-1));

       End;{New Block Black, Old Block Black}





      If Black_Or_White(TempCol,TempRow) then
       PutImage(Get_BlockX(TempCol),Get_BlockY(TempRow),White^,0)

      Else
          PutImage(Get_BlockX(TempCol),Get_BlockY(TempRow),Black^,0);

      If (TempCol<>Col) Or (TempRow<>Row)  Then
         Piece_Pos[TempCol,TempRow]:=100;

      End;{If (Col<>TempCol) Or (Row<>TempRow)}

     Click_One:=False;
     ShowMouse;
     Repeat until Not(Mouseclicked);
     Player1:=Not(Player1);




     If (Player1=True) Then SetFillStyle(1,4)
      Else  SetFillStyle(1,1);
      Bar(554,246,610,282);

    SetColor(7);
    SetTextStyle(1,HorizDir,2);
    If Check=RedKing Then SetColor(4);
      OuttextXY(557,163,'ллллл');

     SetColor(7);

    If Check=BlueKing Then SetColor(1);
       OuttextXY(557,178,'ллллл');
     SetTextStyle(0,HorizDir,1);
        SetColor(63);
   OutTextXy(570,172,'RED');
   OutTextXY(566,189,'BLUE');


  End;{If (Click_One) and (Row<>' ') And (Col<>' ') And MouseClicked}



 End;{Procedure Clicked}

Procedure DialogBox;
{To draw a dialog box on the screen}
Begin
     SetFillStyle(1,7);
     SetLineStyle(0,0,1);
     Bar(155,144,469,335);
     SetColor(56);
     Rectangle(155,144,469,335);

     SetColor(63);
     Line(155,144,469,144);
     Line(469,144,469,335);


End;



Procedure NewGame;
Begin
     OuttextXY(200,6,'New Game');

     {Initialize the Piece_Pos Array}


    For Column:= '1' to '8' do
      For Rows:= 'A' to 'H' do
        Piece_Pos[Column,Rows]:=100;


    For Column:='1' to '8' do
     For Rows:='C' to 'F' do
       Begin
         If Black_Or_White(Column,Rows) then
          PutImage(Get_BlockX(Column),Get_BlockY(Rows),White^,0)
         Else
          PutImage(Get_BlockX(Column),Get_BlockY(Rows),Black^,0);


       End;{For. This puts Blank spaces in the middle section of the board
           So that a new game can be started}


 {This Puts the pieces in their starting positions}

  Place_Piece('1','A',7);
  Place_Piece('2','A',4);
  Place_Piece('3','A',8);
  Place_Piece('4','A',2);
  Place_Piece('5','A',1);
  Place_Piece('6','A',9);
  Place_Piece('7','A',5);
  Place_Piece('8','A',6);
  Place_Piece('1','B',11);
  Place_Piece('2','B',10);
  Place_Piece('3','B',11);
  Place_Piece('4','B',10);
  Place_Piece('5','B',11);
  Place_Piece('6','B',10);
  Place_Piece('7','B',11);
  Place_Piece('8','B',10);



   Place_Piece('1','H',18);
  Place_Piece('2','H',17);
  Place_Piece('3','H',21);
  Place_Piece('4','H',15);
  Place_Piece('5','H',12);
  Place_Piece('6','H',20);
  Place_Piece('7','H',16);
  Place_Piece('8','H',19);
  Place_Piece('1','G',22);
  Place_Piece('2','G',23);
  Place_Piece('3','G',22);
  Place_Piece('4','G',23);
  Place_Piece('5','G',22);
  Place_Piece('6','G',23);
  Place_Piece('7','G',22);
  Place_Piece('8','G',23);


  Player1:=False;
  Display_Date;
 {This resets the Check block}
  SetColor(7);
  SetTextStyle(1,HorizDir,2);

  OuttextXY(557,163,'ллллл');
  OuttextXY(557,178,'ллллл');

  SetTextStyle(0,HorizDir,1);
    SetColor(63);
   OutTextXy(570,172,'RED');
   OutTextXY(566,189,'BLUE');
 {This Resets the Player block}
  If (Player1=True) Then SetFillStyle(1,4)
      Else  SetFillStyle(1,1);
      Bar(554,246,610,282);
  Click_One:=False;

End;


Procedure LoadGame;

Var OldScreen:Pointer;
    Clicked:Boolean;
    X,y:Word;

Begin
     HideMouse;
     OuttextXY(200,6,'LoadGame');

     Assign(Data,'C:\Project\Saves.dat');
     Reset(Data);

  {This Gets the Area of the screen that is to be covered by the dialog
      box into memory so that it can be redrawn after the function has
      been completed}

     GetMem(OldScreen,(ImageSize(149,141,470,337)));
     GetImage(149,141,470,337,OldScreen^);

     DialogBox;{This Goes to a procedure to draw a dialog Box for Load
                Save, New Game and Exit}
     OutTextXy(175,155,'Load Game');

     For i:=0 to 3 do                           {This draws the}
       RectButton(175,(180+I*30),225,20,False); { selection boxes}
        RectButton(400,305,60,18,False);

      SetColor(56);
     OuttextXY(407,310,'Cancel');
    ShowMouse;

     SetColor(4);
     For I:= 1 to (FileSize(Data)) Do
      Begin
        Seek(Data,(I-1));
        Read(Data,SaveDetails);
        OuttextXY(180,(187+(I-1)*30),SaveDetails.Name);
      End;

      SetColor(56);
      If (FileSize(Data)<4) then
       For i:=3 downto (FileSize(Data)) Do
        OuttextXY(180,(187+(I)*30),'Empty Slot');

      Repeat
         Clicked:=False;
         Display_Date;
         If (MouseClicked) Then
          Begin
           GetMousePos(X,Y);

            If (InHotSpot(X,Y,175,180,400,200) And MouseClicked) then
              Begin {Button 1}
                 RectButton(175,180,225,20,True);
                 If FileSize(Data)>=1 then
                  Begin {Button 1}
                  Seek(Data,0);
                  Clicked:=True;
                  End;

                 Repeat Until Not(MouseClicked);

              End;{Button 1}

            If (InHotSpot(X,Y,175,210,400,230) And MouseClicked) then
              Begin
                 RectButton(175,210,225,20,True);
                 If FileSize(Data)>1 then
                  Begin {Button 2}
                  Seek(Data,1);

                  Clicked:=True;
                  End;

                  Repeat Until Not(MouseClicked);
              End;{Button 2}

             If (InHotSpot(X,Y,175,240,400,260) And MouseClicked) then
              Begin{Button 3}
                 RectButton(175,240,225,20,True);
                 If FileSize(Data)>2 then
                  Begin
                   Seek(Data,2);
                   Clicked:=True;
                  End;

                  Repeat Until Not(MouseClicked);
              End;{Button 3}

             If (InHotSpot(X,Y,175,270,400,290) And MouseClicked) then
              Begin {Button 4}

                 RectButton(175,270,225,20,True);
                 If FileSize(Data)>3 then
                  Begin
                   Seek(Data,3);
                   Clicked:=True;
                  End;

                  Repeat Until Not(MouseClicked);
              End;{Button 4}

             If (InHotSpot(X,Y,400,305,460,323) And MouseClicked) then
                Begin {Button CANCEL}

                 RectButton(400,305,60,18,True);

                  Close(Data);

                 HideMouse;
                 PutImage(149,141,OldScreen^,NormalPut);
                 ShowMouse;
                 FreeMem(OldScreen,(ImageSize(149,141,470,337)));

                 EXIT;
              End;{Button CANCEL}

       End;{If MouseClicked}
     Until Clicked;

     {This puts back the image that was covered by the Dialog Box}
      HideMouse;
      PutImage(149,141,OldScreen^,NormalPut);
      FreeMem(OldScreen,(ImageSize(149,141,470,337)));


    {This Reads the data from the file and  transfers it to the program}
     Read(Data,SaveDetails);
     { Set_Color(60,20,20,20);
      Set_Color(4,10,10,10);
      Set_Color(57,30,30,30);
      Set_Color(1,20,20,20); }
     With SaveDetails Do
      Begin
        Player1:=Player;

        For Column:='1' to '8' do
         For Rows:='A' to 'H' do
          Begin
             If (Piece_Pos[Column,Rows]<>BoardSetup[Column,Rows]) Then
            Begin
             If Black_Or_White(Column,Rows) then
             PutImage(Get_BlockX(Column),Get_BlockY(Rows),White^,0)
             Else
              PutImage(Get_BlockX(Column),Get_BlockY(Rows),Black^,0);

           Piece_Pos[Column,Rows]:=BoardSetup[Column,Rows];
           If (Piece_Pos[Column,Rows]<100) Then
            Place_Piece(Column,Rows,Piece_Pos[Column,Rows]);
          End;{If Piece-Pos array is not equal to loaded array}
       End;{For}


     End;{With}

      Close(Data);
      ShowMouse;

    {This checks the loaded game for Check}
      SetColor(7);
    SetTextStyle(1,HorizDir,2);
    If Check=RedKing Then SetColor(4);
      OuttextXY(557,163,'ллллл');

     SetColor(7);

    If Check=BlueKing Then SetColor(1);
       OuttextXY(557,178,'ллллл');
     SetTextStyle(0,HorizDir,1);
        SetColor(63);
   OutTextXy(570,172,'RED');
   OutTextXY(566,189,'BLUE');
  Click_One:=False;

     Repeat until Not(MouseClicked);

End;{Procedure LoadGame}

Procedure SaveGame;
Var
   OldScreen:Pointer;
   Clicked:Boolean;
   X,Y:Word;

Begin
     SetColor(4);
     OuttextXY(200,6,'Save Game');
     Assign(Data,'C:\Project\Saves.dat');
     ReSet(Data);

  {This Gets the Area of the screen that is to be covered by the dialog
      box into memory so that it can be redrawn after the function has
      been completed}

     GetMem(OldScreen,(ImageSize(149,141,470,337)));
     GetImage(149,141,470,337,OldScreen^);
     HideMouse;
     DialogBox;{This Goes to a procedure to draw a dialog Box for Load
                Save, New Game and Exit}
     OutTextXy(175,155,'Save Game');


     For i:=0 to 3 do                           {This draws the}
       RectButton(175,(180+I*30),225,20,False); { selection boxes}
        RectButton(400,305,60,18,False);

      SetColor(56);
     OuttextXY(407,310,'Cancel');


     SetColor(4);                                     {This Writes the     }
     For I:= 1 to (FileSize(Data)) Do                 {Details of the Save-}
      Begin                                           {Game on the buttons }
        Seek(Data,(I-1));                             {that have been drawn}
        Read(Data,SaveDetails);
        OuttextXY(180,(187+(I-1)*30),SaveDetails.Name);
      End;

      SetColor(56);                                {This Writes Empty on   }
      If (FileSize(Data)<4) then                   {Buttons for which there}
       For i:=3 downto (FileSize(Data)) Do         {no records stored on   }
        OuttextXY(180,(187+(I)*30),'Empty Slot');  {file                   }
      ShowMouse;

      Repeat
         Clicked:=False;
         Display_Date;
         If (MouseClicked) Then
          Begin
           GetMousePos(X,Y);

            If (InHotSpot(X,Y,175,180,400,200) And MouseClicked) then
              Begin
                 RectButton(175,180,225,20,True);
                 Seek(Data,0);
                 Repeat Until Not(MouseClicked);
                 Clicked:=True;
              End;

            If (InHotSpot(X,Y,175,210,400,230) And MouseClicked) then
              Begin
                 RectButton(175,210,225,20,True);
                 If FileSize(Data)>1 then
                  Seek(Data,1)
                  Else Seek(Data,FileSize(Data));
                  Clicked:=True;
                  Repeat Until Not(MouseClicked);
              End;

             If (InHotSpot(X,Y,175,240,400,260) And MouseClicked) then
              Begin
                 RectButton(175,240,225,20,True);
                 If FileSize(Data)>2 then
                  Seek(Data,2)
                  Else Seek(Data,FileSize(Data));
                  Clicked:=True;
                  Repeat Until Not(MouseClicked);
              End;

             If (InHotSpot(X,Y,175,270,400,290) And MouseClicked) then
              Begin
                 RectButton(175,270,225,20,True);
                 If FileSize(Data)>3 then
                  Seek(Data,3)
                  Else Seek(Data,FileSize(Data));
                  Clicked:=True;
                  Repeat Until Not(MouseClicked);
              End;

             If (InHotSpot(X,Y,400,305,460,323) And MouseClicked) then
                Begin


                   RectButton(400,305,60,18,True);



                Close(Data);
                 HideMouse;
                 PutImage(149,141,OldScreen^,NormalPut);
                 ShowMouse;
                 FreeMem(OldScreen,(ImageSize(149,141,470,337)));

                 EXIT;
              End;


     Repeat until Not(MouseClicked);




       End;{If MouseClicked}

      Until Clicked;

     With SaveDetails Do
      Begin
        Player:=Player1;

        For Column:='1' to '8' do
         For Rows:='A' to 'H' do
        BoardSetup[Column,Rows]:=Piece_Pos[Column,Rows];

       {  GetTime(Hour,Minute,Second,HundSec);
        Str(Hour,StrHour);
        Str(Minute,StrMin);}
        Name:=Date+' '+Time;

     End;{With}

    Write(Data,SaveDetails);
     Close(Data);


     HideMouse;
     PutImage(149,141,OldScreen^,NormalPut);
     ShowMouse;
     FreeMem(OldScreen,(ImageSize(149,141,470,337)));

     Repeat until Not(MouseClicked);
     SetLineStyle(0,0,3);

End;{Procedure SaveGame}

Procedure ExitGame;
Begin
     SetTextStyle(1,Horizdir,4);
     OuttextXY(100,200,'GoodBye');
     Delay(10);
     Halt;
End;




Procedure Menu(Button:Integer);
{This procedure is called of the user clicks one of the buttons on the left
 of the chess board}
Begin
    SetColor(7) ;
    OuttextXY(200,6,'лллллллллл');
    SetColor(4);
    SetLineStyle(0,0,3);
     Case Button of
          0:EXIT;
          1:Begin

               SqrButton(13,55,70,True);
               NewGame;
               Repeat until Not(MouseClicked);
            End;{Button 1}

          2:Begin

               SqrButton(13,150,70,True);


               LoadGame;
            End;{Button 2}

          3:Begin

             SqrButton(13,246,70,True);
             SaveGame;
            End;{Button 3}

          4:Begin
              SqrButton(13,343,70,True);
             ExitGame;
            End;{Button4}


     End;{Case Button of}
       SetLineStyle(0,0,3);
End;{Procedure Menu}

Procedure AI;
{randomizes a move}
Var rancol,c,r:cHAR;
    Ranrow:CHAR;
Begin

     randomize;

{ If not(Click_One) then
 Begin
      repeat
     Rancol:=CHR(RAndom(8)+49);
     Ranrow:=UPCASE(chr(random(8)+97));
      until (Piece_Pos[Rancol,Ranrow]>12);
  CLICK(rANCOL,RANROW);
 end;}



  While player1 do
   Begin
    Repeat
     Rancol:=CHR(RAndom(8)+49);
     Ranrow:=UPCASE(chr(random(8)+97));
    Until (Piece_Pos[Rancol,Ranrow]>12);

  c:='0';
  r:='A';

  While (player1) and (r<>'I') do
  Begin

   Inc(c);
   If c='9' then inc(r);
   If c='9' then c:='1';

   setcolor(4);
   outtextxy(5,2,R+RanRow);
   outtextxy(20,2,C+ranCol);

   If r<>'I' then
    Begin
     Click(c,r);
     CLICk(rANCOL,RANROW);
     Delay(00);
     Click(c,r);
    End;

   Setcolor(7);
   Outtextxy(5,2,R+ranRow);
   Outtextxy(20,2,C+rancol);

  End;


 End;



End;




Procedure Map;
{This Procedure will map each block on the chess board}
Var XTEMP,YTEMP,Error,Button:Integer;
    Col,Row:Char;
Begin
Startmouse;
Showmouse;
Click_One:=False;
Repeat


    Getmousepos(xm,xy);
    Display_Date;

Val(Xpos,XTEMP,Error);
Val(Ypos,YTEMP,Error);

If (XTEMP<>XM) OR (YTEMP<>XY) then
   Begin
   {Write over the previous co-ordinates in black to erase them}
      {Convert the new co-ordinates from Word to String variable type}
    Str(Xm,XPOS);
    Str(XY,YPOS);


    SetColor(7);
   OuttextXY(570,88,'лллл');
   OutTextXY(555,105,'ллллллл');

   SetColor(0);
   Display_Date;
   Row:=' ';
   Col:=' ';

  IF ((XM>100) AND (XM<520)) AND ((XY>48) AND (XY<431)) Then

 Begin

   Case XM  of

      102..149:col:='1';
      155..204:col:='2';
      207..257:col:='3';
      260..309:col:='4';
      312..362:col:='5';
      365..414:col:='6';
      417..467:col:='7';
      470..520:col:='8';
    Else Col:=' ';
   End;


  Case XY Of

       49..93:Row:='A';
       97..141:Row:='B';
       144..189:Row:='C';
       193..237:Row:='D';
       240..285:Row:='E';
       289..333:Row:='F';
       337..381:Row:='G';
       385..430:Row:='H';
    Else Row:=' ';
  End;{Case XY OF}


  OuttextXY(575,88,Row);
  OuttextXY(583,88,Col);

 If (Col<>' ') and (Row<>' ') then
  Begin
   If (Piece_Pos[col,row]<12) then Setcolor(4)
    Else SetColor(1);
   If Piece_Pos[col,Row]=100 then Setcolor(15);



  CASE Piece_Pos[Col,Row] of
       0,1,12,13:OuttextXY(558,105,' KING');
       2,3,14,15:OuttextXY(555,105,' QUEEN');
       4,5,16,17:OuttextXY(552,105,' KNIGHT');
       6,7,18,19:OuttextXY(558,105,' ROOK');
       8,9,20,21:OuttextXY(559,105,'BISHOP');
       10,11,22,23:OuttextXY(558,105,' PAWN');
     {  100:OuttextXY(100,15,'Blank');}
   End;

 Setcolor(15);
End;


End;{IF}

    Button:=0;

    IF ((XM<83) And (XM>14)) Then
     Begin
       Display_Date;
       Case XY Of
         55..125:Button:=1;
         150..220:Button:=2;
         246..316:Button:=3;
         343..413:Button:=4;
         Else Button:=0;
       End;{Case XY of}




     End;


   End;{IF}

  Setcolor(15);


 If MouseClicked Then Menu(Button);
 If MouseClicked then Click(col,row);

 if player1 then AI;



Until Xy>500 {Keypressed};
End;

Procedure File_Create;
{This checks if there is a save game file on the disk. If not, the
 procedure will create one}
Begin

   Assign(Data,'C:\Project\Saves.dat');
 {$I-}
 Reset(Data);
 {$I+}
 If IOResult <> 0 then
   Rewrite(Data);{If the file does not exist, create one}

 Close(Data);

End;{Procedure File_Create}


Procedure Draw_Surround;
{This procedure draws the board and board surround such as buttons menus etc}
Begin
    {Draw the Chess Board surround}


       SetFillStyle(1,7);
       Bar(0,0,640,480);

       SetColor(63);
      SetLineStyle(0,0,1);
      Rectangle(0,0,638,478);
      SetColor(56);
       SetLineStyle(0,0,3);
       Line(1,479,640,479);
       Line(639,0,639,480);




   PutImage(70,30, Board1^, NormalPut);
       PutImage(290,30, Board2^, NormalPut);

  FreeMem(Board1,ImageSize(80,10,300,440));
  FreeMem(Board2,ImageSize(80,10,300,440));

   Bar(40,440,600,462);
   Bar(40,10,600,40);

  {This draws the buttons on the side of the screen}
    SetFillStyle(1,7);
    SetLineStyle(0,0,3);
    SqrButton(13,55,70,False);
    SqrButton(13,150,70,False);
    SqrButton(13,246,70,False);
    SqrButton(13,343,70,False);


     SetColor(4);
     SetTextStyle(0,Horizdir,1);
   OuttextXY(35,85,'New ');
   OuttextXY(30,180,'Load');
   OuttextXY(30,276,'Save');
   OuttextXY(30,373,'Exit');
   OutTextXY(554,45,'Current');


   SetColor(0);
   OutTextXy(551,73,'Position');
   OutTextXy(575,88,'E5');
   OutTextXy(560,154,'Check');
   OutTextXy(560,235,'Player');

   SetColor(63);
   OutTextXy(570,172,'RED');
   OutTextXY(566,189,'BLUE');

   Indent_Button(537,42,90,395);{Current}
   Indent_Button(552,84,60,40);{Position}
   Indent_Button(552,164,60,40);{Check}
   Indent_Button(552,244,60,40);{Player}
   RectButton(0,0,640,20,False);

End;{DrawSurround}



Procedure Pictures;
{This procedure gets the images from a BMP file with a unit procedure, and
 then captures the images into memory}
Begin
   {Get image of Chess board}
     {Load image from BMP file}
    load_bmp(20,20,'c:\Project\board3.bmp',result);

     Size := ImageSize(80,10,300,440);
      GetMem(Board1, Size); { Get memory from heap }
      GetImage(80,10,300,440,Board1^);

      GetMem(Board2,(Imagesize(300,10,580,440)));
      GetImage(300,10,580,440,Board2^);





{Clear Screen and get next picture}


     Load_BMP(0,0,'c:\project\pieces.BMP',result);



   Size:=Imagesize(90,290,148,350);



FOR I:=0 to 11 do
   Begin
    Getmem(Red[I],Size);
    GetMem(Blue[I],Size);
   End;
    GetMem(Black,Size);
    GetMem(White,Size);

{Get Blue Pieces}

     GetImage(94,250,144,295,Blue[0]^);
      GetImage(147,250,196,295,Blue[1]^);
      GetImage(199,250,249,295,Blue[2]^);
      GetImage(252,250,301,295,Blue[3]^);
      GetImage(304,250,354,295,Blue[4]^);
      GetImage(357,250,406,295,Blue[5]^);
      GetImage(409,250,459,295,Blue[6]^);
      GetImage(462,250,511,295,Blue[7]^);


      GetImage(94,202,144,247,Blue[8]^);
      GetImage(147,202,196,247,Blue[9]^);
      GetImage(199,202,249,247,Blue[10]^);
      GetImage(252,202,301,247,Blue[11]^);



{Get Red Pieces}
      GetImage(94,346,144,391,Red[0]^);
      GetImage(147,346,196,391,Red[1]^);
      GetImage(199,346,249,391,Red[2]^);
      GetImage(252,346,301,391,Red[3]^);
      GetImage(304,346,354,391,Red[4]^);
      GetImage(357,346,406,391,Red[5]^);
      GetImage(409,346,459,391,Red[6]^);
      GetImage(462,346,511,391,Red[7]^);


      GetImage(94,298,144,343,Red[8]^);
      GetImage(147,298,196,343,Red[9]^);
      GetImage(199,298,249,343,Red[10]^);
      GetImage(252,298,301,343,Red[11]^);

{Get Blank Squares}
     GetImage(304,298,354,343,White^);
     GetImage(357,298,406,343,Black^);

End;{Procedure Pictures}

BEGIN


     GD:=detect;
     initgraph(GD,GM,'c:\tp\bgi\');


     Set_color(3,0,0,0);
     Set_color(63,0,0,0);
     Set_color(56,0,0,0);
     Set_color(57,0,0,0);
     Set_color(60,0,0,0);
     Set_color(1,0,0,0);
     Set_color(4,0,0,0);
     Set_Color(7,0,0,0);


 Pictures;


Clearviewport;




 Draw_Surround;

 Newgame;

     Set_Color(57,20,20,63);
    Set_color(56,20,20,20);
    Set_color(60,63,20,20);
    Set_Color(7,40,40,40);

    For i:=10 to 45 do
    Begin
    Set_color(4,I,0,0);
    Set_color(1,0,0,I);
    Set_Color(63,(I+18),(I+18),(I+18));
    set_color(3,(I+18),(I+18),(I+18));
    Delay(10);
    End;
   FadeDown(63);



 File_Create;

 Map;

END. {Main Program}