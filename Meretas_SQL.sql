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
	ChoiceID INT NOT NULL,
	CONSTRAINT PK_QuestionResponse PRIMARY KEY (QuestionID, SurveyID, ChoiceID, SurveyResponseID),
	CONSTRAINT FK_QuestionResponseChoices FOREIGN KEY (ChoiceID, QuestionID, SurveyID) REFERENCES Choices(ChoiceID, QuestionID, SurveyID),
	CONSTRAINT FK_QuestionResponseSurveyResponse FOREIGN KEY (SurveyResponseID) REFERENCES SurveyResponse(SurveyResponseID)
)
GO
CREATE TABLE CreditCards 
(
	CreditCardID INT IDENTITY(1,1),
	CreditCardName NVARCHAR(100) NOT NULL,
	CardImage VARBINARY(MAX) NULL,
	RedirectLink NVARCHAR(2083) NULL,
	DateAdded DATE NOT NULL,
	TimeAdded TIME(0) NOT NULL,
	IsRemoved BIT NOT NULL,
	DateRemoved DATE NULL,
	TimeRemoved TIME(0) NULL,
	CONSTRAINT PK_CreditCards PRIMARY KEY (CreditCardID)
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
	WeightedValue INT NOT NULL,
	CONSTRAINT PK_ChoiceAttributes PRIMARY KEY (QuestionID, SurveyID, ChoiceID, AttributeID),
	CONSTRAINT FK_ChoiceAttributesChoices FOREIGN KEY (ChoiceID, QuestionID, SurveyID) REFERENCES Choices(ChoiceID, QuestionID, SurveyID),
	CONSTRAINT FK_ChoiceAttributesAttributes FOREIGN KEY (AttributeID) REFERENCES Attributes(AttributeID)
)
GO
CREATE TABLE CreditCardAttributes
(
	CreditCardID INT NOT NULL,
	AttributeID INT NOT NULL,
	WeightedValue INT NOT NULL,
	CONSTRAINT PK_CreditCardAttributes PRIMARY KEY (CreditCardID, AttributeID),
	CONSTRAINT FK_CreditCardAttributesCreditCards FOREIGN KEY (CreditCardID) REFERENCES CreditCards(CreditCardID),
	CONSTRAINT FK_CreditCardAttributesAttributes FOREIGN KEY (AttributeID) REFERENCES Attributes(AttributeID)
)
GO
/*Solution 2 tables*/
CREATE TABLE CreditCardProperties 
(
	CreditCardID INT NOT NULL,
	Type NVARCHAR(10) NOT NULL,
	EmploymentStatus NVARCHAR(15) NOT NULL,
	Features NVARCHAR(15) NOT NULL,
	Balance NVARCHAR(3) NOT NULL
	CONSTRAINT PK_CreditCardProperties PRIMARY KEY (CreditCardID),
	CONSTRAINT FK_CreditCardPropertiesCreditCards FOREIGN KEY (CreditCardID) REFERENCES CreditCards(CreditCardID)
)
GO


/*Stored Procedures*/
/*Pre-Conditions*/
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

/*ADD USERS*/
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

/*ADD CREDIT CARDS*/
CREATE PROCEDURE AddCreditCard 
	@CreditCardName NVARCHAR(100),
	@CardImage VARBINARY(MAX),
	@RedirectLink NVARCHAR(2083),
	@DateAdded DATE,
	@TimeAdded TIME(0),
	@CreditCardID INT OUTPUT
AS
	--TRUE is converted to 1 and FALSE is converted to 0.
	IF(@CreditCardName IS NOT NULL AND @RedirectLink IS NOT NULL)
		BEGIN
			BEGIN TRANSACTION
			INSERT INTO CreditCards(CreditCardName, CardImage, RedirectLink, DateAdded, TimeAdded, IsRemoved)
			VALUES(@CreditCardName, @CardImage, @RedirectLink, @DateAdded, @TimeAdded, 0)

			SET @CreditCardID = SCOPE_IDENTITY()

			IF @@ERROR<>0
				ROLLBACK TRANSACTION
			ELSE
			BEGIN
				COMMIT TRANSACTION

				SELECT @CreditCardID
			END
		END
GO
/*REMOVE CREDIT CARDS*/
CREATE PROCEDURE RemoveCreditCard 
	@CreditCardID INT, 
	@DateRemoved DATE,
	@TimeRemoved TIME(0)
AS
	IF(@CreditCardID IS NOT NULL AND
		@DateRemoved IS NOT NULL)
	BEGIN
		BEGIN TRANSACTION
			UPDATE CreditCards
			SET IsRemoved=1,
				DateRemoved=@DateRemoved,
				TimeRemoved=@TimeRemoved
			WHERE CreditCardID=@CreditCardID

			IF @@ERROR<>0
				ROLLBACK TRANSACTION
			ELSE
				COMMIT TRANSACTION	
	END
GO

/*POPULATE SURVEY*/
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

/*WEIGHTED VALUES*/
CREATE PROCEDURE AddAttribute 
	@AttributeText NVARCHAR(20)
AS
	IF(@AttributeText IS NOT NULL)
	BEGIN
		BEGIN TRANSACTION 
		INSERT INTO Attributes(AttributeText)
		VALUES(@AttributeText)

		IF @@ERROR<>0
			ROLLBACK TRANSACTION
		ELSE
			COMMIT TRANSACTION
	END
GO
CREATE PROCEDURE AddCreditCardAttribute
	@CreditCardID INT,
	@AttributeID INT,
	@WeightedValue INT
AS
	IF(@CreditCardID IS NOT NULL AND
		@AttributeID IS NOT NULL AND
		@WeightedValue IS NOT NULL)
	BEGIN
		INSERT INTO CreditCardAttribute(CreditCardID, AttributeID, WeightedValue)
		VALUES(@CreditCardID, @AttributeID, @WeightedValue)

		IF @@ERROR<>0
			ROLLBACK TRANSACTION
		ELSE
			COMMIT TRANSACTION
	END
GO
CREATE PROCEDURE AddChoiceAttribute
	@QuestionID INT,
	@SurveyID INT,
	@ChoiceID INT,
	@AttributeID INT,
	@WeightedValue INT
AS
	IF(@QuestionID IS NOT NULL AND 
		@SurveyID IS NOT NULL AND
		@ChoiceID IS NOT NULL AND
		@AttributeID IS NOT NULL AND 
		@WeightedValue IS NOT NULL)
	BEGIN
		BEGIN TRANSACTION 
		INSERT INTO ChoiceAttributes(QuestionID, SurveyID, ChoiceID, AttributeID, WeightedValue)
		VALUES(@QuestionID, @SurveyID, @AttributeID, @WeightedValue)

		IF @@ERROR<>0
			ROLLBACK TRANSACTION
		ELSE
			COMMIT TRANSACTION 
	END
GO

/*LOAD SURVEY*/
CREATE PROCEDURE LoadQuestions
	@SurveyID INT
AS
	SELECT	QuestionID,
			QuestionText
	FROM Questions
	WHERE SurveyID=@SurveyID
GO
CREATE PROCEDURE LoadChoices
	@QuestionID INT
AS
	SELECT	ChoiceID,
			ChoiceText
	FROM Choices
	WHERE QuestionID=@QuestionID
GO

/*Process Survey*/
CREATE PROCEDURE SubmitSurvey 
	@SurveyID INT,
	@MemberID INT,
	@DateSubmitted DATE,
	@TimeSubmitted TIME,
	@SurveyResponseID INT OUTPUT
AS
	IF(@SurveyID IS NOT NULL AND
		@DateSubmitted IS NOT NULL AND
		@TimeSubmitted IS NOT NULL)
		BEGIN
			BEGIN TRANSACTION
			INSERT INTO SurveyResponse(SurveyID, MemberID, DateSubmitted, TimeSubmitted)
			VALUES(@SurveyID, @MemberID, @DateSubmitted, @TimeSubmitted)
			
			SET @SurveyResponseID = SCOPE_IDENTITY()

			IF @@ERROR<>0
				ROLLBACK TRANSACTION
			ELSE
			BEGIN
				COMMIT TRANSACTION
				SELECT @SurveyResponseID
			END
		END
GO
CREATE PROCEDURE RecordUserResponse 
	@SurveyResponseID INT,
	@SurveyID INT,
	@QuestionID INT, 
	@ChoiceID INT
AS
	IF(@SurveyResponseID IS NOT NULL)
	BEGIN
		BEGIN TRANSACTION
		INSERT INTO QuestionResponse(SurveyID, QuestionID, SurveyResponseID, ChoiceID)
		VALUES(@SurveyID, @QuestionID, @SurveyResponseID, @ChoiceID)

		IF @@ERROR<>0
			ROLLBACK TRANSACTION
		ELSE
			COMMIT TRANSACTION
	END
GO

/*Solution 2*/
CREATE PROCEDURE AddCreditCardProperties 
	@CreditCardID INT,
	@Type NVARCHAR(10),
	@EmploymentStatus NVARCHAR(15),
	@Features NVARCHAR(15),
	@Balance NVARCHAR(3)
AS
	BEGIN TRANSACTION
	INSERT INTO CreditCardProperties(CreditCardID, Type, EmploymentStatus, Features, Balance)
	VALUES(@CreditCardID, @Type, @EmploymentStatus, @Features, @Balance)

	IF @@ERROR<>0
		ROLLBACK TRANSACTION
	ELSE
		COMMIT TRANSACTION
GO
CREATE PROCEDURE GetUserResponse 
	@SurveyID INT,
	@QuestionID INT,
	@ChoiceID INT,
	@SurveyResponseID INT
AS
	SELECT	Choices.ChoiceID, 
			Choices.ChoiceText
	FROM Choices, QuestionResponse, SurveyResponse
	WHERE	Choices.QuestionID=QuestionResponse.QuestionID
		AND QuestionResponse.SurveyResponseID=SurveyResponse.SurveyResponseID
		AND	Choices.ChoiceID=QuestionResponse.ChoiceID
		AND Choices.SurveyID=QuestionResponse.SurveyID
		AND Choices.SurveyID=@SurveyID 
		AND Choices.QuestionID=@QuestionID
		AND Choices.ChoiceID=@ChoiceID
		AND QuestionResponse.SurveyResponseID=@SurveyResponseID
GO
CREATE PROCEDURE RecommendCreditCards 
	@Type NVARCHAR(10),
	@EmploymentStatus NVARCHAR(15),
	@Features NVARCHAR(15),
	@Balance NVARCHAR(3)
AS
	SELECT TOP 2	CreditCards.CreditCardName 
	FROM			CreditCards,
					CreditCardProperties
	WHERE CreditCards.CreditCardID=CreditCardProperties.CreditCardID
			AND CreditCardProperties.Type=@Type
			AND CreditCardProperties.EmploymentStatus=@EmploymentStatus
			AND CreditCardProperties.Features=@Features
			AND CreditCardProperties.Balance=@Balance
GO



SELECT * from questions

EXECUTE AuthenticateLogin 'test@email.ca', 'password123'
EXECUTE AddMember 'user2@email.ca', 'user2'
EXECUTE AddAdmin 'admin5@email.ca', 'admin5'

EXECUTE AddSurvey 'Credit Card Survey'
EXECUTE AddQuestion 1, 'What type of card are you looking for?'
EXECUTE AddChoice 1, 1, 'Personal'

EXECUTE AddQuestion 1, 'Have you recently been discharged from bankruptcy or credit counselling?' --SurveyID,QuestionText
EXECUTE AddChoice 1, 5, 'No'--SurveyID, QuestionID, ChoiceText

EXECUTE AddQuestion 1, 'Do you plan to carry a balance for longer than 6 months?'
EXECUTE AddChoice 1, 4, 'No'

EXECUTE AddCreditCard 'TD Classic Travel Visa Card', NULL, 'https://www.tdcanadatrust.com/products-services/banking/credit-cards/view-all-cards/classic-travel.jsp', '4/18/2017', '12:10 PM'
EXECUTE AddCreditCardProperties 1, 'Personal', 'Full Time', 'Travel Rewards', 'No'

EXECUTE AddCreditCard 'CIBC Aventura Visa Infinite Card', NULL, 'https://www.cibc.com/en/personal-banking/credit-cards/travel-rewards-cards/aventura-visa-infinite.html'
EXECUTE AddCreditCardProperties 2, 'Personal', 'Full Time', 'Cash Back', 'No'

EXECUTE AddCreditCard 'CIBC Aventura Visa Card for Business', NULL, 'https://www.cibc.com/ca/small-business/credit-cards/aventura-visa-card-for-bus.html'
EXECUTE AddCreditCardProperties 3, 'Business', 'Self-employed', 'Travel Rewards', 'No'

EXECUTE AddCreditCard 'TD Emerald Visa Card', NULL, 'https://www.tdcanadatrust.com/products-services/banking/credit-cards/view-all-cards/emerald-card.jsp'
EXECUTE AddCreditCardProperties 4, 'Personal', 'Full Time', 'Travel Rewards', 'Yes'

EXECUTE AddCreditCard 'TD Cash Back MasterCard Card', NULL, 'https://www.tdcanadatrust.com/products-services/banking/credit-cards/view-all-cards/cashback-master-card.jsp'
EXECUTE AddCreditCardProperties 5, 'Personal', 'Full Time', 'Cash Back', 'No'

EXECUTE RemoveCreditCard 1, '4/18/2017', '12:12 PM'

EXECUTE LoadQuestions 1
EXECUTE LoadChoices 2

DECLARE @SurveyResponse INT
EXECUTE SubmitSurvey 1, NULL, '4/12/2017', '11:24 AM', @SurveyResponse /*SurveyID, MemberID, DateSubmitted, TimeSubmitted*/
EXECUTE RecordUserResponse 7, 1, 2, 3 /*SurveyResponseID, SurveyID, QuestionID, ChoiceID*/

EXECUTE GetUserResponse 1, 1, 1, 3 /*SurveyID, QuestionID, ChoiceID*/
EXECUTE RecommendCreditCards 'Personal', 'Full Time', 'Cash Back', 'No', 'No' /*Type, EmploymentStatus, Features, Balance, Discharged*/

SELECT*FROM Choices
SELECT*FROM Questions
SELECT*FROM Surveys
SELECT*FROM Members
SELECT*FROM CreditCards
SELECT*FROM CreditCardProperties
SELECT*FROM Attributes
SELECT*FROM SurveyResponse
SELECT*FROM QuestionResponse

DELETE FROM Questions DBCC CHECKIDENT(Questions, RESEED, 0) 
DELETE FROM Choices DBCC CHECKIDENT(Choices, RESEED, 0)
DELETE FROM Members DBCC CHECKIDENT(Members, RESEED, 0)
DELETE FROM QuestionResponse
DELETE FROM SurveyResponse DBCC CHECKIDENT(SurveyResponse, RESEED, 0)
DELETE FROM CreditCards

/*WEIGHTED VALUES*/
SELECT*FROM CreditCardAttributes
SELECT*FROM ChoiceAttributes


