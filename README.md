<div align="center">
  <img width="320px" src="/assets/images/ttt" />
</div>

## Background
t

Link to the deliverable section: [Link Text](##Insights).


## Technologies Used
* An **OpenAI GPT-5.4 API** connection powers the **AI Agent**’s reasoning engine.
* The Make.com JSON blueprints used for **workflow automation** are available here.
* The **SQL** queries used to examine the final data and perform quality checks are available here.
* The **Power BI dashboard** for review sentiment trends & analysis is available here.
* **Google Sheets** is used for cloud data input.
* **Google Drive** is used for cloud storage.
* **Fivetran** is the **ELT** used to transfer the data from Google Drive to Google BigQuery.
* **Google BigQuery** is used for data warehousing.
* A **Slack** API connection allows the AI to message a customer support channel about urgent reviews.



## Executive Summary
t


## Project Architecture
t


# Component 1 - AI Sentiment Analysis Workflow
This primary workflow automatically analyzes review sentiment daily with an OpenAI GPT-5.4 API, evaluating previous-day reviews to generate key metrics including a polarity sentiment score from -1.0 to 1.0, sentiment category, topic, and emotion.

These new metrics are combined with the original review metadata in a central table to power downstream analytics, including the up-to-date dashboard. Additionally, the agentic AI can alert customer support via Slack if it deems a review to be urgent.

<div align="center">
  <img width="320px" src="/assets/images/ttt" />
</div

(?)This workflow securely logs customer reviews daily. It first safeguards original data to ensure no review is lost, then uses an AI agent to analyze sentiment, and flag urgent feedback to your support team on Slack.

### **Data Retrieval & Safeguarding**
1. Automatically trigger every morning at 7:30 AM.
2. Retrieve all rows from the *customer_reviews_raw* table (available here) where the date is the previous day.
    <details>
      <summary>Example input & output</summary>
    
    ```json
    INPUT
    [
      {
        "from": "drive",
        "filter": [
          [
            {
              "a": "B",
              "b": "07/10/2026",
              "o": "date:equal"
            }
          ]
        ],
        "sheetId": "Sheet1",
        "sortOrder": "asc",
        "spreadsheetId": "privacy",
        "tableFirstRow": "A1:CZ1",
        "includesHeaders": true,
        "valueRenderOption": "FORMATTED_VALUE",
        "dateTimeRenderOption": "FORMATTED_STRING"
      }
    ]
    
    OUTPUT
    [
      {
        "0": "468",
        "1": "7/10/2026",
        "2": "4",
        "3": "Apple AirTag",
        "4": "Technology",
        "5": "Nice to have a little bit of security when you attach it something you can walk away from for a while.",
        "__ROW_NUMBER__": 469,
        "__SPREADSHEET_ID__": "privacy",
        "__SHEET__": "Sheet1",
        "__IMTLENGTH__": 10,
        "__IMTINDEX__": 1
      }
    ]
    ```
    
    </details>

3. Count the number of returned rows. If there are no reviews from yesterday (zero rows), end the workflow. If there are any reviews from yesterday (≤1 row), continue the workflow.
4. Input the original columns (id, date, rating, product, category, and comments) into the *customer_reviews_processed* table (available here) before any AI logic.
    - This ensures that if the AI API fails, the original information is still carried over to the new table for data integrity purposes and can be re-analyzed later.

      <details>
        <summary>Example input & output</summary>
      
      ```json
      INPUT
      [
        {
          "from": "drive",
          "mode": "select",
          "values": {
            "0": "468",
            "1": "7/10/2026",
            "2": "4",
            "3": "Apple AirTag",
            "4": "Technology",
            "5": "Nice to have a little bit of security when you attach it something you can walk away from for a while."
          },
          "sheetId": "Sheet1",
          "spreadsheetId": "privacy",
          "includesHeaders": true,
          "insertDataOption": "INSERT_ROWS",
          "useColumnHeaders": false,
          "valueInputOption": "USER_ENTERED",
          "insertUnformatted": false
        }
      ]
      
      OUTPUT
      [
        {
          "spreadsheetId": "privacy",
          "tableRange": "Sheet1!A1:O468",
          "updates": {
            "spreadsheetId": "privacy",
            "updatedRange": "Sheet1!A469:F469",
            "updatedRows": 1,
            "updatedColumns": 6,
            "updatedCells": 6
          },
          "sheetName": "Sheet1",
          "rowNumber": 469
        }
      ]
      ```
      
      </details>

### **AI Logic & Analysis**
5. Yesterday’s reviews, now retrieved, are given to the AI model for sentiment analysis and urgency detection.
    * No text aggregation is needed before analysis, as the agentic AI aggregates the rows automatically.
6. The AI’s reasoning engine is powered by an OpenAI GPT-5.4 API connection.
7. The AI is instructed to analyze each review to determine the following metrics:
    * sentiment (VADER polarity score -1.0 to 1.0)
    * confidence
    * rating_consistency (0/1 binary)
    * main_topic
    * secondary_topic
    * emotion
    * action_needed (if the AI flags a review as urgent)
    * drafted_response (professional email response if the review was negative)
    * sentiment_category
8. The AI then inputs this new data into the *customer_reviews_processed* table, using the row's original id primary key to ensure each review matches correctly.
9. To execute this task, the AI is authorized to read and update rows in the *customer_reviews_processed* table.
10. The AI is also instructed to evaluate whether the current review it is analyzing is urgent.
Urgency is defined for the AI as a review whose comments require immediate human intervention (e.g., threats, asking a question, wants to return/refund, product safety issue, severe bugs, etc.).
11. The AI is authorized to send a message in a specified Slack channel to alert support staff, at its discretion, if it deems a review to be urgent.

The full prompt for the AI’s instructions is available here.

<details>
  <summary>📄 Full AI prompt instructions</summary>

**Prompt file is also available here.**
```md
t
```

</details>



<details>
  <summary>⚙️ Example AI Run #1</summary>

### Analysis for Review ID #266

**1. AI Reasoning**
```md
Searching for rows
"I need to search for specific rows and then update a matching row based on the results. The comments feel urgent since there’s a question that needs action. I'll draft a response only if the sentiment is negative. We have some confusion since the score is around -0.2. I need to consider the other metrics, too. Let's search to find this review's corresponding row in the table."
```

**2. 'Search Rows' tool is called**
```json
{
  "array": [
    {
      "0": "266",
      "1": "5/8/2026",
      "2": "2",
      "3": "Stanley Thermos",
      "4": "Food & Drink Container",
      "5": "I have a question. Was there to be some kind of a cap on the straw part? Everyone seems to think so, yet there was no cap for the straw on the Stanley that I received.",
      "__ROW_NUMBER__": 267,
      "__SPREADSHEET_ID__": "privacy",
      "__SHEET__": "Sheet1",
      "__IMTLENGTH__": 3,
      "__IMTINDEX__": 3
    }
  ]
}
```

**3. AI Reasoning**
```md
Processing sentiment analysis
"I’m determining a sentiment score of -0.22, which indicates a mixed feeling due to some confusion and slight dissatisfaction. My confidence in this is at 0.86, which is pretty good. I see the main topic relates to product completeness or missing components, while a secondary topic might be about customer inquiries regarding the product delivery. It sounds urgent to answer their question on whether a straw cap is included, verify the product contents, and possibly offer a replacement if needed."
```

**4. 'Update a Row' tool is called**
 
Input:
```json
{
  "values_6": "-0.22",
  "values_7": "0.82",
  "values_8": "1",
  "values_9": "Missing Components",
  "values_10": "Product Inquiry",
  "values_11": "Confused",
  "values_12": "Answer the customer's question about whether a straw cap should have been included, confirm the expected contents of the product, and offer a replacement or missing part if applicable.",
  "values_13": "",
  "values_14": "Mixed",
  "rowNumber": 267
}
```

Output:
```json
{
  "spreadsheetId": "privacy",
  "updatedRange": "Sheet1!A267:O267",
  "updatedRows": 1,
  "updatedColumns": 9,
  "updatedCells": 9
}
```

**5. 'Send a Slack Message' tool is called**

Input:
```md
🚨 The following review from yesterday is urgent, and the customer should be contacted:
• Review #266 with a 2/5 rating and Mixed sentiment.
• The customer is Confused.
• See the review for further details.
```

Output:
```json
{
  "type": 0,
  "content": "🚨 The following review from yesterday is urgent, and the customer should be contacted:\n• Review #266 with a 2/5 rating and Mixed sentiment.\n• The customer is Confused.\n• See the review for further details.",
  "mentions": [],
  "mention_roles": [],
  "attachments": [],
  "embeds": [],
  "timestamp": "privacy",
  "edited_timestamp": null,
  "flags": 0,
  "components": [],
  "id": "privacy",
  "channel_id": "privacy",
  "author": {
    "id": "privacy",
    "username": "Urgent_Review_Alert",
    "avatar": "privacy",
    "discriminator": "privacy",
    "public_flags": 0,
    "flags": 0,
    "bot": true
  },
  "pinned": false,
  "mention_everyone": false,
  "tts": false
}
```

**6. AI Reasoning**
```md
"Done. Review #266 was analyzed, updated in the sheet, and flagged as urgent in Slack."
```

</details>

### Example review:
**Review #370 Before:**

| id | date | rating | product | category | comments |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 370 | 6/7/2026 | 5 | Nike Men's Running Sneaker | Shoes | Absolutely love them long time Nike wearer and so far these are the best highly recommend. |



**Review #370 After:**
| id | date | rating | product | category | comments | sentiment | confidence | rating_consistency | main_topic | secondary_topic | emotion | action_needed | drafted_response | sentiment_category |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 370 | 6/7/2026 | 5 | Nike Men's Running Sneaker | Shoes | Absolutely love them long time Nike wearer and so far these are the best highly recommend. | 0.94 | 0.98 | 1 | Product Quality | Brand Loyalty | Satisifed | null | null | Positive |



## Component 2 - AI Executive Summary Workflow
t


## Component 3 - SQL Data Validation
t


## Component 4 - Power BI Dashboard
t


## Insights
t


## Recommendations
t


## Future Improvements & Limitations
t


<details>
  <summary>Example input & output</summary>

```json
INPUT
t
```

</details>
