

USE csun13

DROP TABLE IF EXISTS dbo.Activity
DROP TABLE IF EXISTS dbo.Assignee
DROP TABLE IF EXISTS dbo.Bug
DROP TABLE IF EXISTS dbo.bugUpdate
DROP TABLE IF EXISTS dbo.EnhancementReleaseList
DROP TABLE IF EXISTS dbo.FeatureTable
DROP TABLE IF EXISTS dbo.Origin
DROP TABLE IF EXISTS dbo.Product
DROP TABLE IF EXISTS dbo.ProductLog
DROP TABLE IF EXISTS dbo.ReleaseVersion
DROP TABLE IF EXISTS dbo.Task
DROP TABLE IF EXISTS dbo.TICKET
DROP TABLE IF EXISTS dbo.UserStory
DROP TABLE IF EXISTS dbo.UserStoryUpdate
DROP TABLE IF EXISTS dbo.VersionFeature
DROP TABLE IF EXISTS dbo.VersionTable
DROP TABLE IF EXISTS dbo.WORKFLOW
DROP TABLE IF EXISTS dbo.Software



/*Create a table that would display the type of software a certain company has. The software table would
include the productID as to reference the unique product of the company*/
CREATE TABLE Software(
    productID int NOT NULL CONSTRAINT FK_productsID FOREIGN KEY (productID) REFERENCES Product(productID),
    companyName varchar(255),
    versionID int CONSTRAINT FK_softwareVersionID FOREIGN KEY (versionID) REFERENCES VersionTable(versionID),
    softwareName varchar(255),
    softwareDescription text,
    PRIMARY KEY(productID,softwareName,companyName)
    )

/*Product table that would reference what kind of product a certain software is*/
CREATE TABLE Product(
    productID int NOT NULL PRIMARY KEY,
    productName varchar(50),
    productDescription text,
    )

/*Version table to keep track of a certain software product.*/
/*The date format for all the tables is as '2020-05-02' (YYYY-MM-DD)*/
CREATE TABLE VersionTable(
    versionID int,
    productID int NOT NULL,
    releasedDate date,
    versionManual text,
    PRIMARY KEY (versionID),
    CONSTRAINT FK_productID FOREIGN KEY (productID) REFERENCES Product(productID)
)


/*Create a activity table whose value are development and support. The activity table indicates whether an enhancement is for new feature or support to existing feature.
Identity indicates that when we add a value to the table the id value keeps increasing automatically.*/
CREATE TABLE Activity(
    activityID tinyint IDENTITY(1,1) PRIMARY KEY,
    activityValue varchar(15),
    )

--DBCC CHECKIDENT (Activity, RESEED, 1)


/*Origin tables refers to the source of origin for a certain issue. Here the values would be company or customer who reported a certain issue. Customer may have value as 
Client1, Client2 and so on. The identity property automatically sets the id number for the user and unique constraint in reporter does now allow for duplicate reporter.*/
CREATE TABLE Origin(
	reportedByID int IDENTITY(1,1) PRIMARY KEY,
	reporter varchar(25) UNIQUE,
	)
	--DBCC CHECKIDENT (Origin, RESEED, 1)

/*Create a ticket table to create issues. Here issues can be a new feature to be implemented or a bug reported by the development team or the customer. The product manager
creates a ticket for this issues and then gives them a priority. I decided to include priority as a integer value because higher the integer value more the priority. 
Issuetype indicates whether the issue is bug, or userStory, or a new Feature to be implemented and I decided to keep its value as a varchar with character limit of 10 words.*/

CREATE TABLE TICKET(
	ticketID int NOT NULL PRIMARY KEY,
	issueType varchar(10),
	ticketdescription varchar(255),
	reportedByID int CONSTRAINT FK_reportedByID FOREIGN KEY (reportedByID) REFERENCES Origin(reportedByID),
	ticketPriority tinyint,
	recordedDate date
	)

	
Alter table Ticket
Add CONSTRAINT FK_reportedByID FOREIGN KEY (reportedByID) REFERENCES Origin(reportedByID);


/*Create a workflow for state which indicates whether the certain issue is active,open or closed*/
CREATE TABLE WORKFLOW(
	stateID tinyint IDENTITY(1,1) PRIMARY KEY,
	stateValue varchar(15) UNIQUE
	)

/*Assignee table to keep the store asignee information. We might have long names so I decided to keep the varchar a little more.*/
CREATE TABLE Assignee(
	assigneeID int PRIMARY KEY,
	assigneeName varchar(255),
	assigneeEmail varchar(255) UNIQUE
	)

/*Create a UserStory table to include all the userStory items in the productlog. AssigneeID references to 
the assignee table where it has name and information of the assignee*/
CREATE TABLE UserStory(
    userStoryID int NOT NULL PRIMARY KEY,
	ticketID int CONSTRAINT FK_ticketID FOREIGN KEY REFERENCES TICKET(ticketID),
    assigneeID int FOREIGN KEY REFERENCES Assignee(assigneeID),
    notificationDate date,
	storyUpdateID int
    )

/*Create UserStoryUpdate to define the status of the issue as open or closed */
CREATE TABLE UserStoryUpdate(
	storyUpdateID int PRIMARY KEY,
	userStoryID int CONSTRAINT FK_userStoryID FOREIGN KEY REFERENCES UserStory(userStoryID),
	stateID tinyint CONSTRAINT FK_stateID FOREIGN KEY REFERENCES WorkFlow(stateID)
	)


/*Adding a foreign key to the UserStory table*/
ALTER TABLE UserStory ADD CONSTRAINT FK_storyUpdateID FOREIGN KEY (storyUpdateID) REFERENCES UserStoryUpdate(storyUpdateID)


/*Task table to list all the tasks in the UserStory. This table is a child of UserStory. I did not create an assignee for task under
the assumption that a single userStory is assigned to only one person. In this case all the tasks in the userStory will go to a single assignee*/
CREATE TABLE Task(
    taskID int PRIMARY KEY,
    userStoryID int CONSTRAINT FK_TaskUserStoryID FOREIGN KEY(userStoryID) REFERENCES UserStory(userStoryID),
    taskDescription text,
    )

/*Bug table to reference bugs. All the issues that were raised in the ticket as bugs will go into this table.*/
CREATE TABLE Bug(
    bugID int PRIMARY KEY,
	ticketID int CONSTRAINT FK_bugTicketID FOREIGN KEY REFERENCES TICKET(ticketID),
	assigneeID int CONSTRAINT FK_assigneeID FOREIGN KEY REFERENCES Assignee(assigneeID),
    notificationDate date,
	bugUpdateID int
    )


/*Create UserStoryUpdate to define the status of the issue as open or closed */

CREATE TABLE bugUpdate(
	bugUpdateID int PRIMARY KEY,
	bugID int CONSTRAINT FK_bugID FOREIGN KEY REFERENCES Bug(bugID),
	stateID tinyint CONSTRAINT FK_bugStateID FOREIGN KEY REFERENCES WorkFlow(stateID)
	)

/*Bugs and UserStory have a one to many relation*/
CREATE TABLE UserStoryBugs(
    userStoryID int,
    bugID int
    )

/*Create a ProductLog table to keep track of all the UserStory and bugs. This table is obtained by joining tables UserStory and bugs*/
CREATE TABLE ProductLog(
   productLogID int NOT NULL IDENTITY(1,1) PRIMARY KEY,
   userStoryID int CONSTRAINT FK_productUserStoryID FOREIGN KEY REFERENCES UserStory(userStoryID),
   bugID int CONSTRAINT FK_productbugID FOREIGN KEY REFERENCES Bug(bugID)
    )


/*Feature table to keep track of features for a certain product that needs to be released for a specific version. Here productLogID retrieves the items to be retrieved from the productLogTable
that will be included as a feature*/
CREATE TABLE FeatureTable(
    featureID int PRIMARY KEY,
	featureDescription text,
    productLogID int CONSTRAINT FK_featureProductLog FOREIGN KEY REFERENCES ProductLog(productLogID)
    )

/*VersionFeature table to link which version has which feature. One version has many features*/
CREATE TABLE VersionFeature(
    versionID int CONSTRAINT FK_versionID FOREIGN KEY REFERENCES VersionTable(versionID) ,
    featureID int CONSTRAINT FK_featureID FOREIGN KEY REFERENCES FeatureTable(featureID)
    )

/*Create a EnhancementRelease list table to store which features to release in a certain version.We want to publish the items from the productLog table as a feature.
For example we want only certain userstory, tasks and bugs to be published in a certain release. Also we want to define the activity is for new development or support for existing version*/
CREATE TABLE EnhancementReleaseList(
    enhancementID int PRIMARY KEY,
	featureListID int CONSTRAINT FK_featureIDForEnhancement FOREIGN KEY REFERENCES FeatureTable(featureID),
    versionID int CONSTRAINT FK_versionForEnhancement FOREIGN KEY REFERENCES VersionTable(versionID),
    activityID tinyint CONSTRAINT FK_activityIDForEnhancement FOREIGN KEY REFERENCES Activity(activityID) 
    )


/*Create a table for release purpose. For the release version I choose varchar because it is easier to insert value as a character rather than int.*/
CREATE TABLE ReleaseVersion(
    releaseVersion varchar(10) PRIMARY KEY,
	enhancementID int CONSTRAINT FK_enhancementID FOREIGN KEY REFERENCES EnhancementReleaseList(enhancementID),
    startDate date,
    releasedDate date,
    )



/*Insert into Assignee table*/
INSERT INTO Assignee values (1, 'Robert','robert@mask-m.net'),(2, 'HushHush', 'developer@mask-met.net'),(3,'Virginia','virginia@mask-me.net'),(4, 'john cxxne','cxxne1111@outlook.com')

/*Insert into Activity table by turning on the identity_insert*/
SET IDENTITY_INSERT activity ON
INSERT INTO Activity(activityID,activityValue) Values (1,'development'),(2,'support')
SET IDENTITY_INSERT activity OFF

/*Insert into origin table by turning on the identity_insert*/
SET IDENTITY_INSERT origin ON
INSERT INTO origin(reportedByID,reporter) Values (1,'client1'),(2,'client2'),(3,'HH')
SET IDENTITY_INSERT origin OFF

/*Insert into ticket table as userstory or bugs*/

INSERT INTO TICKET (ticketID,issueType,ticketdescription,reportedByID,ticketPriority,recordedDate)
	VALUES (2342,'UserStory','Current layout needs change to the new look',1,2,'2018-01-30')
INSERT INTO TICKET (ticketID,issueType,ticketdescription,reportedByID,ticketPriority,recordedDate)
	VALUES (2345,'UserStory','Preparing Site for New Products Promotion',1,1,'2018-01-30')

INSERT INTO TICKET (ticketID,issueType,ticketdescription,reportedByID,ticketPriority,recordedDate)
	VALUES (23409,'UserStory','SALES: develop a template',1,1,'2018-01-30')

INSERT INTO TICKET (ticketID,issueType,ticketdescription,reportedByID,ticketPriority,recordedDate)
	VALUES (2332,'Bug','Web Site, Training Center: create a sub menu for the Masking Demo',1,2,'2018-01-30')
INSERT INTO TICKET (ticketID,issueType,ticketdescription,reportedByID,ticketPriority,recordedDate)
	VALUES (2312,'Bug','Selected Menu Item Does Not Change Color',2,2,'2018-01-30'),
		(2319,'Bug','Hints under the menu items',1,2,'2018-01-30')


/*Select tickets which are reported by client1*/
SELECT * from ticket a join origin b on a.reportedByID= b.reportedByID 
where b.reportedByID =1


/*Insert into workflow*/
SET IDENTITY_INSERT Workflow ON
INSERT INTO WORKFLOW(stateID,stateValue) VALUES (1,'New'),(2,'Closed')
SET IDENTITY_INSERT WORKFLOW OFF


/*Insert those tickets and bugs into their respective tables*/
INSERT INTO Bug(bugID,ticketID,assigneeID,notificationDate)
	VALUES (4587,2312,1,'2018-02-03'),
		(4572,2319,2,'2018-02-01'),(4563,2332,1,'2018-02-01')

INSERT INTO UserStory(userStoryID,ticketID,assigneeID,notificationDate)
	VALUES (4520,2342,1,'2018-02-03'),(4522,2345,2,'2018-02-03')



  

/*Select all userstory that is assigned to a particular person*/
SELECT * from UserStory a join Assignee b on a.assigneeID= b.assigneeID 
where b.assigneeID =1


/*Union UserStory table and BugTable*/
SELECT bugID,ticketID,assigneeID,notificationDate FROM Bug
    UNION
    SELECT userStoryID,ticketID,assigneeID,notificationDate FROM UserStory




