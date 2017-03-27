USE lachica1_Meretas


CREATE TABLE Members 
(
	MemberID INT NOT NULL, 
	MemberEmail NVARCHAR(120) NOT NULL,
	MemberPassword NVARCHAR(120) NOT NULL,
	IsAdmin BIT NOT NULL
	CONSTRAINT PK_MemberID PRIMARY KEY (MemberID)
)
GO
CREATE TABLE Surveys
(
	SurveyID INT NOT NULL,
	SurveyDescription NVARCHAR(40) NOT NULL,
	CONSTRAINT PK_SurveyID PRIMARY KEY (SurveyID)
)
GO
CREATE TABLE SurveyResponse
(
	SurveyID INT NOT NULL,
	MemberID INT NULL,
	DateSubmitted DATE NOT NULL,
	TimeSubmitted TIME NOT NULL, 
	CONSTRAINT PK_SurveyInstance PRIMARY KEY (SurveyID),
	CONSTRAINT FK_SurveyInstanceSurveys FOREIGN KEY (SurveyID) REFERENCES Surveys(SurveyID),
	CONSTRAINT FK_SurveyInstanceMembers FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
)
GO
CREATE TABLE Questions
(
	SurveyID INT NOT NULL,
	QuestionID INT NOT NULL,
	QuestionText NVARCHAR(100) NOT NULL,
	CONSTRAINT PK_Questions PRIMARY KEY (SurveyID, QuestionID),
	CONSTRAINT FK_QuestionsSurveys FOREIGN KEY (SurveyID) REFERENCES Surveys(SurveyID),
)
GO
CREATE TABLE Choices
(
	ChoiceID INT NOT NULL,
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
	CONSTRAINT FK_QuestionResponseQuestions FOREIGN KEY (QuestionID, SurveyID) REFERENCES Questions(QuestionID),
	CONSTRAINT FK_QuestionResponseSurveyResponse FOREIGN KEY (SurveyResponseID) REFERENCES SurveyResponse(SurveyResponseID)
)
GO
CREATE TABLE Attributes
(
	
)
GO