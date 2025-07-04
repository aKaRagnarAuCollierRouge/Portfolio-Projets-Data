VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "DayButtonHandler"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Public WithEvents DAYBUTTON As MSForms.CommandButton
Attribute DAYBUTTON.VB_VarHelpID = -1

Private Sub DAYBUTTON_MouseMove(ByVal Button As Integer, ByVal Shift As Integer, ByVal X As Single, ByVal Y As Single)
    Dim dayValue As Variant
    dayValue = Me.DAYBUTTON.Caption
    
    ' V�rifier si la valeur du jour est num�rique
    If IsNumeric(dayValue) Then
        ' Appeler PreparateDatasDay pour obtenir les donn�es pour le jour s�lectionn�
        Dim data As Scripting.Dictionary
        Set data = PreparateDatasDay(Calendar.CurrentYearCalendar, Calendar.CurrentMonthCalendar + 1, CInt(dayValue))
        
        ' Mettre � jour les valeurs dans l'interface utilisateur avec les donn�es du jour s�lectionn�
        Calendar.TradesTakenDayValue = data("NbWin") + data("NbLoose")
        Calendar.NbWinDayValue = data("NbWin")
        Calendar.NbLooseDayValue = data("NbLoose")
        Calendar.GainDayValue = data("Gain")
        Calendar.LossDayValue = data("Loss")
        Calendar.PourcentWinDayValue = data("PourcentWin")
        Calendar.PourcentLooseDayValue = data("PourcentLoose")
        Calendar.RRAverageDayValue = IIf(Calendar.TradesTakenDayValue > 0, data("RRAverage"), 0)
        Calendar.RRGainDayValue = data("RRGain")
        Calendar.RRLossDayValue = data("RRLoss")
        Calendar.TotalProfitRRValue = data("RRAverage") * Calendar.TradesTakenDayValue
        
        ' R�initialiser d'autres valeurs � 0 si n�cessaire (assurez-vous de les ajuster selon votre logique)
        Calendar.PourcentGainDayValue = data("PourcentGain")
        Calendar.PourcentLoosDayValue = data("PourcentLoss")
        
        'Changement DayCommentary
        Dim fileJ As Variant
        Dim Commentary As String
        
        ' Load JSON data for the given year
        Set fileJ = Loadjson(Calendar.CurrentYearCalendar)
        Commentary = GetCommentaryDay(fileJ, Calendar.CurrentMonthCalendar + 1, dayValue)
        Calendar.DayCommentary = Commentary
    Else
        ' Si la valeur du jour n'est pas num�rique, r�initialiser toutes les valeurs � 0
        Calendar.PourcentGainDayValue = 0
        Calendar.PourcentLoosDayValue = 0
        Calendar.LossDayValue = 0
        Calendar.PourcentLooseDayValue = 0
        Calendar.PourcentWinDayValue = 0
        Calendar.TradesTakenDayValue = 0
        Calendar.NbLooseDayValue = 0
        Calendar.NbWinDayValue = 0
        Calendar.RRAverageDayValue = 0
        Calendar.RRGainDayValue = 0
        Calendar.RRLossDayValue = 0
        Calendar.TotalProfitRRValue = 0
        Calendar.GainDayValue = 0
        
        'Changement DayCommentary
        Calendar.DayCommentary = ""
        
        
        ' Vous pouvez ajouter ici un message de d�bogage ou une notification si n�cessaire
        Debug.Print "Aucune statistique disponible pour le jour " & dayValue & "."
    End If
End Sub

Private Sub DAYBUTTON_Click()
    Dim year As Integer
    Dim month As Integer
    Dim day As String
    Debug.Print ("Zbigito")
    day = Me.DAYBUTTON.Caption
    
    If day <> "" Then
        ' Obtenir le mois et l'ann�e actuels du calendrier (supposons que Calendar soit le nom de votre calendrier)
        month = Calendar.CurrentMonthCalendar
        year = Calendar.CurrentYearCalendar
        ' Add one month
    newMonth = Calendar.CurrentMonthCalendar + 1

    ' Add one year
    newYear = Calendar.CurrentYearCalendar

        ' Valider et convertir la journ�e en entier
        If IsNumeric(day) Then
         Dim dayForm As New DayResume
         
            dayForm.DateResumeDay = DateSerial(newYear, newMonth, CInt(day))
            dayForm.Show
        Else
            MsgBox "Le jour doit �tre un nombre valide."
        End If
    Else
        MsgBox "Veuillez s�lectionner une journ�e valide."
    End If
End Sub

Public Function PreparateDatasDay(year As Integer, month As Integer, day As Integer) As Scripting.Dictionary
    Dim NbWinDay As Integer
    Dim NbLooseDay As Integer
    Dim GainDay As Double
    Dim LossDay As Double
    Dim PourcentWinDay As Double
    Dim PourcentLooseDay As Double
    Dim PourcentGainDay As Double
    Dim PourcentLossDay As Double
    Dim RRAverageDay As Double
    
    Dim RRDayTotal As Double
    Dim RRGainDay As Double
    Dim RRLooseDay As Double
    
    Dim ColonneRR As Integer
    Dim ColonneGain As Integer
    Dim ColonneDateDebut As Integer
    Dim tableName As String
    Dim row As Variant
    Dim RR As Double
    Dim Gain As Double
    Dim data As Scripting.Dictionary
    Dim TotalTrades As Integer
    Dim wsTrackrecord As Worksheet
    
    ' R�initialiser les variables pour le jour
    NbWinDay = 0
    NbLooseDay = 0
    GainDay = 0
    LossDay = 0
    RRDayTotal = 0
    RRGainDay = 0
    RRLooseDay = 0
    
    PourcentWinDay = 0
    PourcentLooseDay = 0
    PourcentGainDay = 0
    PourcentLossDay = 0
    RRAverageDay = 0
    
    Set wsTrackrecord = ThisWorkbook.Sheets("Trackrecord")
    tableName = "Tableau1"
    ColonneRR = FindIndiceCollumnWithTable(wsTrackrecord, tableName, "RR")
    ColonneGain = FindIndiceCollumnWithTable(wsTrackrecord, tableName, "Gain")
    ColonneDateDebut = FindIndiceCollumnWithTable(wsTrackrecord, tableName, "Date D�but")
    
    Dim RowFiltered As Collection
    
    ' Appeler la fonction FiltreRowByDate pour obtenir les lignes filtr�es pour la journ�e sp�cifi�e
    Set RowFiltered = FiltreRowByDate(DateSerial(year, month, day), DateSerial(year, month, day) + TimeSerial(23, 59, 59), ColonneDateDebut, "Trackrecord")
    
    ' Boucler sur les lignes filtr�es pour calculer les statistiques pour la journ�e
    For Each row In RowFiltered
        RR = row(1, ColonneRR)
        Gain = row(1, ColonneGain)
        
        ' Calculer les variables pour la journ�e
        If RR > 0 Then
            NbWinDay = NbWinDay + 1
            RRGainDay = RRGainDay + RR
        Else
            NbLooseDay = NbLooseDay + 1
            RRLooseDay = RRLooseDay + RR
        End If
        
        RRDayTotal = RRDayTotal + RR
        
        If Gain > 0 Then
            GainDay = GainDay + Gain
        Else
            LossDay = LossDay + Gain ' Gain est n�gatif ici
        End If
    Next row
    
    ' Calcul des pourcentages pour la journ�e
    TotalTrades = NbWinDay + NbLooseDay
    
    If TotalTrades > 0 Then
        PourcentWinDay = NbWinDay / TotalTrades * 100
        PourcentLooseDay = NbLooseDay / TotalTrades * 100
    End If
    
    If (GainDay + LossDay) <> 0 Then
        PourcentGainDay = GainDay / (GainDay + LossDay) * 100
        PourcentLossDay = LossDay / (GainDay + LossDay) * 100
    End If
    
    ' Calcul de la moyenne de RR pour la journ�e
    If TotalTrades > 0 Then
        RRAverageDay = RRDayTotal / TotalTrades
    End If
    
    ' Cr�er un nouveau dictionnaire pour stocker les r�sultats
    Set data = New Scripting.Dictionary
    data("NbWin") = NbWinDay
    data("NbLoose") = NbLooseDay
    data("Gain") = GainDay
    data("Loss") = LossDay
    data("PourcentWin") = PourcentWinDay
    data("PourcentLoose") = PourcentLooseDay
    data("PourcentGain") = PourcentGainDay
    data("PourcentLoss") = PourcentLossDay
    data("RRAverage") = RRAverageDay
    data("RRGain") = RRGainDay
    data("RRLoss") = RRLooseDay
    
    ' Retourner le dictionnaire
    Set PreparateDatasDay = data
End Function

