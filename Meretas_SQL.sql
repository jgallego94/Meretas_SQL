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
CREATE TABLE SurveyInstance 
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
CREATE TABLE 
(
)
GO
