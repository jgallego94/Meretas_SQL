/*USE lachica1_Meretas*/

CREATE TABLE Members 
(
	MemberID INT IDENTITY(1,1), 
	MemberEmail NVARCHAR(120) NOT NULL,
	MemberPassword NVARCHAR(120) NOT NULL,
	IsAdmin BIT NOT NULL
	CONSTRAINT PK_MemberID PRIMARY KEY (MemberID)
)
GO
CREATE TABLE Surveys
(
	SurveyID INT IDENTITY(1,1),
	SurveyText NVARCHAR(40) NOT NULL,
	CONSTRAINT PK_SurveyID PRIMARY KEY (SurveyID)
)
GO
CREATE TABLE SurveyResponse
(
	SurveyResponseID INT IDENTITY(1,1),
	SurveyID INT NOT NULL,
	MemberID INT NULL,
	DateSubmitted DATE NOT NULL,
	TimeSubmitted TIME NOT NULL, 
	CONSTRAINT PK_SurveyInstance PRIMARY KEY (SurveyResponseID),
	CONSTRAINT FK_SurveyInstanceSurveys FOREIGN KEY (SurveyID) REFERENCES Surveys(SurveyID),
	CONSTRAINT FK_SurveyInstanceMembers FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
)
GO
CREATE TABLE Questions 
(
	QuestionID INT IDENTITY(1,1),
	SurveyID INT NOT NULL,
	QuestionText NVARCHAR(100) NOT NULL,
	CONSTRAINT PK_Questions PRIMARY KEY (QuestionID, SurveyID),
	CONSTRAINT FK_QuestionsSurveys FOREIGN KEY (SurveyID) REFERENCES Surveys(SurveyID),
)
GO
CREATE TABLE Choices
(
	ChoiceID INT IDENTITY(1,1),
	QuestionID INT NOT NULL,
	SurveyID INT NOT NULL,
	ChoiceText NVARCHAR(120),
	CONSTRAINT PK_Choices PRIMARY KEY (ChoiceID, QuestionID, SurveyID),
	CONSTRAINT FK_ChoicesQuestions FOREIGN KEY (QuestionID, SurveyID) REFERENCES Questions(QuestionID, SurveyID)
)
GO
CREATE TABLE QuestionResponse
(	
	QuestionID INT NOT NULL,
	SurveyID INT NOT NULL,
	SurveyResponseID INT NOT NULL,
	ResponseText NVARCHAR(1),
	CONSTRAINT PK_QuestionResponse PRIMARY KEY (QuestionID, SurveyID, SurveyResponseID),
	CONSTRAINT FK_QuestionResponseQuestions FOREIGN KEY (QuestionID, SurveyID) REFERENCES Questions(QuestionID, SurveyID),
	CONSTRAINT FK_QuestionResponseSurveyResponse FOREIGN KEY (SurveyResponseID) REFERENCES SurveyResponse(SurveyResponseID)
)
GO
CREATE TABLE Attributes
(
	AttributeID INT NOT NULL,
	AttributeText NVARCHAR(20) NOT NULL,
	CONSTRAINT PK_Attibutes PRIMARY KEY (AttributeID)
)
GO
CREATE TABLE ChoiceAttributes
(
	QuestionID INT NOT NULL,
	SurveyID INT NOT NULL,
	ChoiceID INT NOT NULL,
	AttributeID INT NOT NULL,
	Value INT NOT NULL,
	CONSTRAINT PK_ChoiceAttributes PRIMARY KEY (QuestionID, SurveyID, ChoiceID, AttributeID),
	CONSTRAINT FK_ChoiceAttributesChoices FOREIGN KEY (ChoiceID, QuestionID, SurveyID) REFERENCES Choices(ChoiceID, QuestionID, SurveyID),
	CONSTRAINT FK_ChoiceAttributesAttributes FOREIGN KEY (AttributeID) REFERENCES Attributes(AttributeID)
)
GO
CREATE TABLE CreditCards
(
	CreditCardID INT IDENTITY(1,1),
	CreditCardName NVARCHAR(100) NOT NULL,
	CardImage VARBINARY(MAX) NULL,
	RedirectLink NVARCHAR(2083) NULL,
	CONSTRAINT PK_CreditCards PRIMARY KEY (CreditCardID)
)
GO
CREATE TABLE CreditCardAttributes
(
	CreditCardID INT NOT NULL,
	AttributeID INT NOT NULL,
	Value INT NOT NULL,
	CONSTRAINT PK_CreditCardAttributes PRIMARY KEY (CreditCardID, AttributeID),
	CONSTRAINT FK_CreditCardAttributesCreditCards FOREIGN KEY (CreditCardID) REFERENCES CreditCards(CreditCardID),
	CONSTRAINT FK_CreditCardAttributesAttributes FOREIGN KEY (AttributeID) REFERENCES Attributes(AttributeID)
)
GO

/*Stored Procedures*/
CREATE PROCEDURE AddMember 
	@UserEmail NVARCHAR(120),
	@UserPassword NVARCHAR(120)
AS
	DECLARE @IsAdmin BIT
	SET @IsAdmin=0 --Not an Admin

	IF (@UserEmail IS NOT NULL)
		IF (@UserPassword IS NOT NULL)
			BEGIN TRANSACTION
				INSERT INTO Members(MemberEmail, MemberPassword, IsAdmin)
				VALUES(@UserEmail, @UserPassword, @IsAdmin)
			IF @@ERROR <> 0
				ROLLBACK TRANSACTION
			ELSE
				COMMIT TRANSACTION
GO
CREATE PROCEDURE AddAdmin
	@AdminEmail NVARCHAR(120),
	@AdminPassword NVARCHAR(120)
AS
	DECLARE @IsAdmin BIT
	SET @IsAdmin=1 --Is an Admin

	IF (@AdminEmail IS NOT NULL)
		IF (@AdminPassword IS NOT NULL)
			BEGIN TRANSACTION
				INSERT INTO Members(MemberEmail, MemberPassword, IsAdmin)
				VALUES(@AdminEmail, @AdminPassword, @IsAdmin)
			IF @@ERROR <> 0
				ROLLBACK TRANSACTION
			ELSE
				COMMIT TRANSACTION
GO
CREATE PROCEDURE AuthenticateLogin
	@UserEmail NVARCHAR(120), 
	@UserPassword NVARCHAR(120)
AS
	DECLARE @UserRole BIT
	
	BEGIN TRANSACTION 
		SELECT MemberID, IsAdmin
		FROM Members
		WHERE MemberEmail=@UserEmail AND 
				MemberPassword=@UserPassword
		
		IF @@ERROR <> 0
			ROLLBACK TRANSACTION
		ELSE
			COMMIT TRANSACTION		
GO

CREATE PROCEDURE AddSurvey
	@SurveyText NVARCHAR(40)
AS
	IF (@SurveyText IS NOT NULL)
	IF NOT EXISTS(SELECT SurveyID FROM Surveys WHERE SurveyText=@SurveyText)
		BEGIN
			BEGIN TRANSACTION --Adds into SurveyTable
				INSERT INTO Surveys(SurveyText)
				VALUES(@SurveyText)
	
			IF @@ERROR <> 0
				ROLLBACK TRANSACTION
			ELSE
				COMMIT TRANSACTION
		END
GO
CREATE PROCEDURE AddQuestion
	@SurveyID INT,
	@QuestionText NVARCHAR(100)
AS
	IF (@SurveyID IS NOT NULL AND @QuestionText IS NOT NULL)
		IF EXISTS(SELECT SurveyID FROM Surveys WHERE SurveyID=@SurveyID)
			BEGIN TRANSACTION
				INSERT INTO Questions(SurveyID, QuestionText)
				VALUES(@SurveyID, @QuestionText)
		
			IF @@ERROR <> 0
				ROLLBACK TRANSACTION
			ELSE
				COMMIT TRANSACTION
GO
CREATE PROCEDURE AddChoice 
	@SurveyID INT,
	@QuestionID INT,
	@ChoiceText NVARCHAR(120)
AS
	IF (@SurveyID IS NOT NULL AND @QuestionID IS NOT NULL AND @ChoiceText IS NOT NULL)
		IF EXISTS(SELECT QuestionID FROM Questions WHERE QuestionID=@QuestionID AND SurveyID=@SurveyID)
			BEGIN TRANSACTION
				INSERT INTO Choices(QuestionID, SurveyID, ChoiceText)
				VALUES(@QuestionID, @SurveyID, @ChoiceText)

			IF @@ERROR <> 0
				ROLLBACK TRANSACTION
			ELSE
				COMMIT TRANSACTION
GO

CREATE PROCEDURE LoadSurvey
	@SurveyID INT 
AS
	IF (@SurveyID IS NOT NULL)
		BEGIN TRANSACTION
			SELECT Questions.QuestionText,
					Choices.ChoiceText
			FROM Questions, Choices
			WHERE Questions.QuestionID=Choices.QuestionID AND
					Questions.SurveyID=(SELECT SurveyID FROM Surveys WHERE SurveyID=@SurveyID)

		IF @@ERROR <> 0
			ROLLBACK TRANSACTION
		ELSE
			COMMIT TRANSACTION
GO


EXECUTE AuthenticateLogin 'test@email.ca', 'password123'
EXECUTE AddMember 'user2@email.ca', 'user2'
EXECUTE AddAdmin 'admin5@email.ca', 'admin5'

EXECUTE AddSurvey 'Credit Card Survey'
EXECUTE AddQuestion 1, 'What type of card are you looking for?'
EXECUTE AddChoice 1, 1, 'Business'

SELECT*FROM Choices
SELECT*FROM Questions
SELECT*FROM Surveys
SELECT*FROM Members

DELETE FROM Choices DBCC CHECKIDENT(Choices, RESEED, 0)
DELETE FROM Members DBCC CHECKIDENT(Members, RESEED, 0)
DELETE FROM Questions DBCC CHECKIDENT(Questions, RESEED, 0) 