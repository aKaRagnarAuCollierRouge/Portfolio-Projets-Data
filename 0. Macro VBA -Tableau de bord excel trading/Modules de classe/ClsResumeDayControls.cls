VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ClsResumeDayControls"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Public WithEvents mFrame As MSForms.Frame
Attribute mFrame.VB_VarHelpID = -1
Public mTradeData As Scripting.Dictionary
Public mControlSet As Collection
Public mDefaultImagePath As String
Public mTopPos As Integer
Public mIndex As Long
Public mControlHeight As Integer

Public mButtons As Collection  ' Collection pour stocker les boutons cr��s
Public Sub Init(Frame As MSForms.Frame, TradeData As Scripting.Dictionary, ByVal TopPos As Integer, DefaultImagePath As String, Index As Long, ControlHeight As Integer)
    ' D�finir les membres de la classe
    Set Me.mFrame = Frame
    Set Me.mTradeData = TradeData
    Me.mTopPos = TopPos
    Me.mDefaultImagePath = DefaultImagePath
    Me.mIndex = Index
    Me.mControlHeight = ControlHeight
    
    ' Initialiser les collections
    Set Me.mControlSet = New Collection
    Set Me.mButtons = New Collection
    
    ' Cr�er les contr�les
    CreateControls
End Sub

Private Sub CreateControls()
    ' Cr�er les labels
    Dim lblDateDebut As MSForms.Label
    Set lblDateDebut = CreateLabel("LabelDateDebut_" & mIndex, "Date D�but: " & Format(mTradeData("Date D�but"), "dd/mm/yyyy"), 10, mTopPos, 130, 20)
    mControlSet.Add lblDateDebut

    Dim lblDateFin As MSForms.Label
    Set lblDateFin = CreateLabel("LabelDateFin_" & mIndex, "Date Fin: " & Format(mTradeData("Date Fin"), "dd/mm/yyyy"), 150, mTopPos, 130, 20)
    mControlSet.Add lblDateFin

    Dim lblHeureEntree As MSForms.Label
    Set lblHeureEntree = CreateLabel("LabelHeureEntree_" & mIndex, "Heure Entr�e: " & Format(mTradeData("Heure Entr�e"), "hh:mm:ss"), 290, mTopPos, 100, 20)
    mControlSet.Add lblHeureEntree

    Dim lblHeureSortie As MSForms.Label
    Set lblHeureSortie = CreateLabel("LabelHeureSortie_" & mIndex, "Heure Sortie: " & Format(mTradeData("Heure Sortie"), "hh:mm:ss"), 400, mTopPos, 100, 20)
    mControlSet.Add lblHeureSortie

    Dim lblActif As MSForms.Label
    Set lblActif = CreateLabel("LabelActif_" & mIndex, "Actif: " & mTradeData("Actif"), 510, mTopPos, 100, 20)
    mControlSet.Add lblActif

    ' Cr�er les boutons de navigation
    Dim btnPrev As MSForms.CommandButton
    Set btnPrev = CreateButton("ButtonPrev_" & mIndex, "<<", 10, mTopPos + 30, 50, 20, 1)
    mControlSet.Add btnPrev

    ' Cr�er la combobox pour les screenshots
    Dim cboScreenshots As MSForms.ComboBox
    Set cboScreenshots = CreateComboBox("ComboBoxScreenshots_" & mIndex, 70, mTopPos + 30, 120, 30)
    PopulateComboBoxWithScreenshots cboScreenshots
    mControlSet.Add cboScreenshots

    ' Cr�er le bouton suivant
    Dim btnNext As MSForms.CommandButton
    Set btnNext = CreateButton("ButtonNext_" & mIndex, ">>", 200, mTopPos + 30, 50, 20, 2)
    mControlSet.Add btnNext

    ' Cr�er le cadre pour l'image
    Dim imgControl As MSForms.Image
    Set imgControl = CreateImage("ImageControl_" & mIndex, 10, mTopPos + 70, 800, 300)
    imgControl.Picture = LoadImage(mDefaultImagePath)
    mControlSet.Add imgControl
End Sub

Private Function CreateLabel(Name As String, Caption As String, Left As Integer, Top As Integer, Width As Integer, Height As Integer) As MSForms.Label
    Dim lbl As MSForms.Label
    Set lbl = mFrame.Controls.Add("Forms.Label.1", Name)
    With lbl
        .Caption = Caption
        .Left = Left
        .Top = Top
        .Width = Width
        .Height = Height
        .Font.Name = "Arial"
        .Font.Size = 12
        .ForeColor = RGB(255, 255, 255)
        .BackColor = RGB(0, 102, 204)
    End With
    Set CreateLabel = lbl
End Function

Private Function CreateButton(Name As String, Caption As String, Left As Integer, Top As Integer, Width As Integer, Height As Integer, Index As Integer) As MSForms.CommandButton
    Dim btn As MSForms.CommandButton
    Set btn = mFrame.Controls.Add("Forms.CommandButton.1", Name)
    With btn
        .Caption = Caption
        .Left = Left
        .Top = Top
        .Width = Width
        .Height = Height
        .Font.Name = "Arial"
        .Font.Size = 12
        .Tag = Index  ' Utilisation de la propri�t� Tag pour stocker l'index
    End With
    ' Ajouter le bouton � la collection de boutons
    mButtons.Add btn
    Set CreateButton = btn
End Function

Private Function CreateComboBox(Name As String, Left As Integer, Top As Integer, Width As Integer, Height As Integer) As MSForms.ComboBox
    Dim cbo As MSForms.ComboBox
    Set cbo = mFrame.Controls.Add("Forms.ComboBox.1", Name)
    With cbo
        .Left = Left
        .Top = Top
        .Width = Width
        .Height = Height
        .Font.Name = "Arial"
        .Font.Size = 12
    End With
    Set CreateComboBox = cbo
End Function

Private Function CreateImage(Name As String, Left As Integer, Top As Integer, Width As Integer, Height As Integer) As MSForms.Image
    Dim img As MSForms.Image
    Set img = mFrame.Controls.Add("Forms.Image.1", Name)
    With img
        .Left = Left
        .Top = Top
        .Width = Width
        .Height = Height
    End With
    Set CreateImage = img
End Function

Private Sub PopulateComboBoxWithScreenshots(cboScreenshots As MSForms.ComboBox)
    ' Ajouter les options de screenshots � la combobox
    cboScreenshots.AddItem mDefaultImagePath ' Ajouter le chemin de l'image par d�faut
    Dim screenshotKey As Variant
    For Each screenshotKey In mTradeData.Keys
        If Left(screenshotKey, 10) = "Screenshot" Then
            cboScreenshots.AddItem mTradeData(screenshotKey)
        End If
    Next screenshotKey
End Sub

Private Function LoadImage(ByVal Filename As String) As StdPicture
    Dim wiaImage As Object
    Set wiaImage = CreateObject("WIA.ImageFile")
    wiaImage.LoadFile Filename
    Set LoadImage = wiaImage.FileData.Picture
End Function

Public Sub UpdateImage()
    Dim screenshotPath As String
    screenshotPath = cboScreenshots.List(cboScreenshots.ListIndex)

    If FileExists(screenshotPath) Then
        imgControl.Picture = LoadImage(screenshotPath)
    Else
        imgControl.Picture = LoadImage(mDefaultImagePath)
    End If
End Sub

Private Function FileExists(FilePath As String) As Boolean
    FileExists = (Dir(FilePath) <> "")
End Function

Private Sub CommandButton_Click()
    ' V�rifier si le contr�le cliqu� est un bouton
    If TypeOf ctrl Is MSForms.CommandButton Then
        Dim btn As MSForms.CommandButton
        Set btn = ctrl
        
        ' R�cup�rer l'index du bouton � partir de la propri�t� Tag
        Dim btnIndex As Integer
        btnIndex = btn.Tag
        
        ' Afficher l'index dans la fen�tre Immediate (Ctrl + G pour afficher la fen�tre Immediate)
        Debug.Print "Index du bouton cliqu� : " & btnIndex
        
        ' Autres actions � effectuer en fonction de l'index r�cup�r�
        Select Case btnIndex
            Case 1
                Debug.Print "Bouton Pr�c�dent cliqu�"
                ' Traitement pour le bouton pr�c�dent
            Case 2
                Debug.Print "Bouton Suivant cliqu�"
                ' Traitement pour le bouton suivant
            ' Ajouter d'autres cas selon les besoins
        End Select
    End If
End Sub
