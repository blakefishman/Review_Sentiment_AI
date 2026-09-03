<div align="center">
  <img width="320px" src="/assets/images/ttt" />
</div>

# Background
**CyberShop.com** is a hypothetical e-commerce platform launched in 2025 that sells various retail goods, including Apple devices, Nike footwear, Stanley drinkware, and more. The business has amassed 467 total reviews since its inception, with most occurring in 2026.

The company lacks systems for analyzing customer feedback beyond basic metadata (e.g., product, rating, comments) for deeper insights. Additionally, there is no alert protocol in place to flag urgent, high-risk reviews for human intervention. Currently, recording review urgency and sentiment characteristics would require manual daily entry.

Automating this process is essential; without it, leadership lacks the up-to-date, actionable visibility required to track review performance and spot deeper emerging trends.

**This project builds an end-to-end pipeline for AI review sentiment analysis.** It combines agentic AI workflows & automations, cloud data storage, Fivetran ELT connection, and BigQuery cloud data warehousing, culminating in a daily batch-processed Power BI dashboard to enable deeper customer insights. Reviews are automatically analyzed daily to determine metrics such as Sentiment, Topic, and Emotion, and a Slack API connection allows the AI agent to alert customer support if it deems a review to be urgent. 

Additionally, a weekly executive summary is generated and delivered via Slack every Monday morning, providing a high-level overview of reviews from the past seven days. This also includes a comparative trend analysis that evaluates the latest seven days against historical reviews to identify long-term patterns.


# Technologies Used
* An **OpenAI GPT-5.4 API** connection powers the **agentic AI**’s reasoning engine.
* The **Make.com** blueprints used for **workflow automation** are available [here](https://github.com/blakefishman/Review_Sentiment_AI/tree/main/Blueprints).
* The **SQL** queries used to examine the final data and perform quality checks are available [here](https://github.com/blakefishman/Review_Sentiment_AI/blob/main/SQL%20Queries/Initial%20Data%20Checks%20and%20Examination.sql).
* The **Power BI dashboard** for review sentiment trends and interactive analysis is available [here](https://github.com/blakefishman/Review_Sentiment_AI/blob/main/Review_Sentiment_Dashboard_PowerBI.pbix).
* **Google Sheets** is used for cloud data input.
* **Google Drive** is used for cloud storage.
* **Fivetran** is the **ELT** used to transfer the data from Google Drive to Google BigQuery.
* **Google BigQuery** is used for data warehousing.
* A **Slack** API connection allows the AI to message a customer support channel about urgent reviews.



# Executive Summary
tt


# Project Architecture
t?


# Component 1 - AI Sentiment Analysis Workflow
This primary workflow automatically analyzes review sentiment daily with an OpenAI GPT-5.4 API, evaluating previous-day reviews to generate key metrics including a polarity sentiment score from -1.0 to 1.0, sentiment category, topic, and emotion.

These new metrics are combined with the original review metadata in a central table to power downstream analytics, including the up-to-date dashboard. Additionally, the agentic AI can alert customer support via Slack if it deems a review to be urgent.


<div align="center">
  <img width="950px" src="https://github.com/blakefishman/Review_Sentiment_AI/blob/main/Images/sentiment_analysis_workflow.png" />
</div>


### **Data Retrieval & Safeguarding**
1. Automatically trigger every morning at 7:30 AM.
2. Retrieve all rows from the *customer_reviews_raw* table (available here) where the date is the previous day.
    <details>
      <summary>⚙️ Example Input & Output</summary>

    Input:
    ```json
    [
      {
        "from": "drive",
        "filter": [
          [
            {
              "a": "B",
              "b": "05/08/2026",
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
    ```

    Output:
    ```json
    [
      {
        "0": "264",
        "1": "5/8/2026",
        "2": "4",
        "3": "Apple AirTag",
        "4": "Technology",
        "5": "Nice to have a little bit of security when you attach it something you can walk away from for a while.",
        "__ROW_NUMBER__": 265,
        "__SPREADSHEET_ID__": "privacy",
        "__SHEET__": "Sheet1",
        "__IMTLENGTH__": 10,
        "__IMTINDEX__": 1
      }
    ]
    ```
    
    </details>

3. Count the number of rows returned. If there are no reviews from yesterday (0 rows), end the workflow. If there are any reviews from yesterday (≥1 rows), continue the workflow.
4. Input these returned rows with their original fields (id, date, rating, product, category, and comments) into the *customer_reviews_processed* table (available here) before any AI logic starts.
    - This ensures that if the AI API fails, the original information is still carried over to the new table for data integrity purposes and can be re-analyzed later.

      <details>
        <summary>⚙️ Example Input & Output</summary>
      
      Input:
      ```json
      [
        {
          "from": "drive",
          "mode": "select",
          "values": {
            "0": "264",
            "1": "5/8/2026",
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
      ```

      Output:
      ```json
      [
        {
          "spreadsheetId": "privacy",
          "tableRange": "Sheet1!A1:O264",
          "updates": {
            "spreadsheetId": "privacy",
            "updatedRange": "Sheet1!A265:F265",
            "updatedRows": 1,
            "updatedColumns": 6,
            "updatedCells": 6
          },
          "sheetName": "Sheet1",
          "rowNumber": 265
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


<details>
  <summary>⚙️ Example AI Run #1</summary>

### AI Sentiment Analysis for Review #266

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

The message:
```md
🚨 The following review from yesterday is urgent, and the customer should be contacted:
• Review #266 with a 2/5 rating and Mixed sentiment.
• The customer is Confused.
• See the review for further details.
```

Input:
```json
[
  {
    "select": "channel",
    "content": "🚨 The following review from yesterday is urgent, and the customer should be contacted:\n• Review #470 with a 2/5 rating and Mixed sentiment.\n• The customer is Confused.\n• See the review for further details.",
    "channelId": "privacy",
    "message_reference": {}
  }
]
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


<details>
  <summary>⚙️ Example AI Run #2</summary>

### AI Sentiment Analysis for Review #50

**1. AI Reasoning**
```md
Analyzing product issues
"I have the review but will need to search for a certain row and then update it. I'll assign a negative sentiment, perhaps around -0.85, with high confidence of this at 0.97. The main topic will be Product Functionality and secondary Comfort, showing an emotion of frustration. I’ve drafted a response for its negative category. I'm considering if the issue is urgent—it's a product malfunction, but there's no immediate safety concern or explicit request for a return or refund. I think it's probably not urgent, but we don't know what is causing the tracking issue. I'll classify it as non-urgent and leave the drafted response for the team's consideration. Now, I just need to search for matching IDs."
```

**2. 'Search Rows' tool is called**
```json
{
  "array": [
    {
      "0": "50",
      "1": "12/3/2025",
      "2": "1",
      "3": "Apple Magic Mouse",
      "4": "Technology",
      "5": "This is my second mac mouse. This one is smaller then the first one i had and really uncomfortable to hold.  I use the mouse all day and many times a day it won't track.  I tried everything, cleaning, turning bluetooth on and off.  Nothing works.  I am just going to get a 10$ mouse and hope it is better.",
      "__ROW_NUMBER__": 51,
      "__SPREADSHEET_ID__": "privacy",
      "__SHEET__": "Sheet1",
      "__IMTLENGTH__": 5,
      "__IMTINDEX__": 5
    }
  ]
}
```

**3. 'Update a Row' tool is called**
 
Input:
```json
{
  "values_6": "-0.86",
  "values_7": "0.97",
  "values_8": "1",
  "values_9": "Functionality",
  "values_10": "Comfort",
  "values_11": "Frustrated",
  "values_12": "",
  "values_13": "Hello,\n\nThank you for sharing your feedback. We’re sorry to hear that the mouse has been uncomfortable to use and that you’ve experienced repeated tracking issues despite troubleshooting. We understand how frustrating this must be, especially when you rely on the mouse throughout the day. We’d appreciate the opportunity to learn more about the issues you encountered and see if there is anything we can do to help address the comfort and performance problems you described.\n\nBest regards,\nCustomer Support",
  "values_14": "Negative",
  "rowNumber": 51
}
```

Output:
```json
{
  "spreadsheetId": "privacy",
  "updatedRange": "Sheet1!A51:O51",
  "updatedRows": 1,
  "updatedColumns": 9,
  "updatedCells": 9
}
```

**4. AI Reasoning**
```md
"Done. Review #50 was analyzed and updated in the sheet."
```

**See Example AI Run #1 for an example with the Slack message functionality.**

</details>

<details>
  <summary>📑 Example Table Row - Before & After</summary>

### Example Table Row for Review #370:
**Before:**

| id | date | rating | product | category | comments |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 370 | 6/7/2026 | 5 | Nike Men's Running Sneaker | Shoes | Absolutely love them long time Nike wearer and so far these are the best highly recommend. |


**After:**
| id | date | rating | product | category | comments | sentiment | confidence | rating_consistency | main_topic | secondary_topic | emotion | action_needed | drafted_response | sentiment_category |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 370 | 6/7/2026 | 5 | Nike Men's Running Sneaker | Shoes | Absolutely love them long time Nike wearer and so far these are the best highly recommend. | 0.94 | 0.98 | 1 | Product Quality | Brand Loyalty | Satisifed | null | null | Positive |

</details>

📂 The full, analyzed database table is available [here](https://github.com/blakefishman/Review_Sentiment_AI/blob/main/Data/reviews_analyzed.csv).

📂 The blueprint.json file is available [here](https://github.com/blakefishman/Review_Sentiment_AI/blob/main/Blueprints/sentiment_analysis.blueprint.json).

📂 The full prompt instructions are available [here](https://github.com/blakefishman/Review_Sentiment_AI/blob/main/Prompts/sentiment_analysis_agentic_prompt.md).


# Component 2 - AI Executive Summary Workflow
This secondary workflow uses an OpenAI GPT-5.4 API to generate weekly executive summaries, delivered to a Slack channel or user. It provides a high-level overview of review performance from the past seven days and highlights long-term trends against older review data from previous months.

The workflow automatically runs every Monday at 9:00 AM to keep key stakeholders updated on customer feedback and sentiment. The comparative trend analysis over previous months helps identify trends and maintain the larger picture.

<div align="center">
  <img width="700px" src="https://github.com/blakefishman/Review_Sentiment_AI/blob/main/Images/executive_summary_workflow.png" />
</div>


### **Data Retrieval**

1. Automatically trigger every Monday at 9:00 AM.
2. Retrieve all rows from the *customer_reviews_processed table* (available here) from within the last seven days.
      <details>
        <summary>⚙️ Example Input & Output</summary>
      
      Input:
      ```json
      [
        {
          "from": "drive",
          "filter": [
            [
              {
                "a": "B",
                "b": "07/04/2026",
                "o": "date:greaterorequal"
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
      ```
      
      Output:
      ```json
      [
        {
          "0": "468",
          "1": "7/10/2026",
          "2": "4",
          "3": "Apple AirTag",
          "4": "Technology",
          "5": "Nice to have a little bit of security when you attach it something you can walk away from for a while.",
          "6": "0.62",
          "7": "0.9",
          "8": "1",
          "9": "Security",
          "10": "Convenience",
          "11": "Satisfied",
          "12": "",
          "13": "",
          "14": "Positive",
          "__ROW_NUMBER__": 469,
          "__SPREADSHEET_ID__": "privacy",
          "__SHEET__": "Sheet1",
          "__IMTLENGTH__": 10,
          "__IMTINDEX__": 1
        }
      ]
      ```
      *+9 more rows*
      
      </details>

3. Aggregate the rows into one AI-parsable text string.
    - Unlike the first workflow, this non-agentic AI connection cannot aggregate data automatically and needs a text string input.
4. Retrieve all rows from the customer_reviews_processed table (available here) from the last three months, but excluding the last seven days.

      <details>
        <summary>⚙️ Example Input & Output</summary>
      
      Input:
      ```json
      [
        {
          "from": "drive",
          "filter": [
            [
              {
                "a": "B",
                "b": "04/11/2026",
                "o": "date:greater"
              },
              {
                "a": "B",
                "b": "07/04/2026",
                "o": "date:less"
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
      ```
      
      Output (truncated for simplicity, as 277 rows were returned):
      ```json
      [
        {
          "0": "191",
          "1": "4/12/2026",
          "2": "4",
          "3": "Apple Magic Mouse",
          "4": "Technology",
          "5": "Apple products just seem to work very well.  I've tried the non-Apple products and have been disappointed every time!  The Apple Magic Mouse works great as did the other  Apple Magic Mouses.  Charging  it was funny, you lay the mouse upside down and connect the charger to the bottom side.  Great product.  Charges last a long time.",
          "6": "0.88",
          "7": "0.95",
          "8": "1",
          "9": "Product Performance",
          "10": "Battery Life",
          "11": "Satisfied",
          "12": "",
          "13": "",
          "14": "Positive",
          "__ROW_NUMBER__": 192,
          "__SPREADSHEET_ID__": "privacy",
          "__SHEET__": "Sheet1",
          "__IMTLENGTH__": 277,
          "__IMTINDEX__": 1
        }
      ]
      ```
      *+276 more rows*
      
      </details>

5. Aggregate these rows into another AI-parsable text string.

### **AI Logic & Analysis**
6. Both review outputs, as aggregated text strings, are given to the AI model to generate the executive summary.
    - The aggregated text strings are isolated into distinct outputs to preserve organization and mitigate AI processing errors
7. The AI’s reasoning engine is powered by an OpenAI GPT-5.4 API connection.
8. The AI is instructed to generate an executive summary based on reviews from the last seven days (the first text string). It also generates a summary comparing these reviews against a three-month trend analysis (the second text string). Consistent formatting rules are specified.

### **Slack Delivery**
9. The AI result is sent to a specific Slack channel or user.


<details>
  <summary>📄 Example Executive Summary Message</summary>

## Last Week’s Reviews (Monday – Sunday)
Over the last 7 days, **10 reviews** were recorded across five products, with an average rating of **3.6/5** and an average sentiment score of approximately **0.39** on a polarity scale of -1.0 to 1.0. Review volume was concentrated in Technology, which accounted for **60%** of all weekly reviews, led by the Apple AirTag and the Apple Magic Mouse. Overall sentiment was mixed: **60%** of reviews were rated **4–5 stars**, while **40%** were rated **1–2 stars**, indicating a polarized customer experience. Positive feedback centered on Apple AirTag’s ease of use, seamless Apple ecosystem integration, and perceived security value, while LEGO and Nike both generated uniformly positive comments tied to gift satisfaction, value, and product appearance.

The week’s main pain points were concentrated in the Apple Magic Mouse and Stanley Thermos. The Apple Magic Mouse produced the sharpest split, with one highly positive performance review offset by two negative reviews focused on **tracking reliability**, **comfort/ergonomics**, and **software incompatibility with macOS Sequoia**. Stanley Thermos also drew a low-rating review related to a **missing straw cap/component**, suggesting a fulfillment or packaging quality issue rather than a core product problem.

## Trend Analysis
Compared with the prior 3 months, review performance over the last 7 days softened modestly. Historical data showed broadly positive feedback, especially for the Apple AirTag, LEGO Toy Set, Nike Men’s Running Sneaker, and Stanley Thermos, with many reviews clustering at **4–5 stars** and recurring praise for reliability, ease of use, value, and strong product performance. Last week’s average rating of **3.6/5** appears somewhat below the historical pattern, driven largely by a higher share of low-rated reviews from a small sample. The most stable positive trend continues to be the Apple AirTag, where customers consistently mention tracking utility, peace of mind, and strong Apple device integration across both periods. LEGO and Nike also remain steady, with no emerging quality concerns and continued positive value perception.

The most persistent negative trend remains the Apple Magic Mouse. Across the historical period, repeated complaints centered on **ergonomics**, the **bottom charging port**, and more recently **USB-C and macOS Sequoia compatibility limitations**; these same compatibility issues reappeared in these last 7 days, indicating no meaningful resolution in customer perception. The Stanley Thermos shows a similar long-running but less severe pattern: while customers consistently praise temperature retention, durability, and design, recurring complaints continue around **leak resistance**, **missing accessories/components**, and inconsistent **packaging/condition on arrival**.

Overall, the past week largely reinforces existing trends rather than introducing new ones: the Apple AirTag remains the strongest and most consistent performer, while the Apple Magic Mouse's compatibility/usability issues and Stanley Thermos packaging/accessory execution continue to be the most actionable areas for improvement.


</details>

📂 The blueprint.json file is available [here](https://github.com/blakefishman/Review_Sentiment_AI/blob/main/Blueprints/executive_summary.blueprint.json).

📂 The full prompt instructions are available [here](https://github.com/blakefishman/Review_Sentiment_AI/blob/main/Prompts/executive_summary_prompt.md).


# Component 3 - Power BI Dashboard
<div align="center">
  <img width="1050px" src="https://github.com/blakefishman/Review_Sentiment_AI/blob/main/Images/dashboard_overview.jpg" />
</div>

The full, interactive dashboard file is available [here](https://github.com/blakefishman/Review_Sentiment_AI/blob/main/Review_Sentiment_Dashboard_PowerBI.pbix).

<details>
  <summary>🖼️ More dashboard views</summary>

<br>

<div align="center">
  <img width="1050px" src="https://github.com/blakefishman/Review_Sentiment_AI/blob/main/Images/dashboard_products.jpg" />
</div>

<br>

<div align="center">
  <img width="1050px" src="https://github.com/blakefishman/Review_Sentiment_AI/blob/main/Images/dashboard_sentiment.jpg" />
</div>

</details>


## Insights
* **Review volume has surged significantly so far this year** compared to the company’s launch last year in 2025. Feedback has stabilized at a 3.8 out of 5-star average rating with a +0.64 average sentiment score, leading to 80% of reviews being Positive.
* **The Stanley Thermos is the strongest-performing product**, with a 4.1 out of 5-star average rating and a +0.75 average sentiment score, leading to 87.6% of reviews being Positive sentiment. Added to the lineup in September 2025, the Stanley Thermos gained significant traction in April 2026 and is currently our second-most reviewed product of all time.
* **Conversely, Apple Magic Mouse is the weakest-performing product**, with a 3.6 out of 5-star average rating and a notably lower average sentiment score of +0.40. It is the source of over half of all negative reviews (52.6%), and over a third of its reviews have Mixed or Negative sentiment. Main friction points center on poor usability, an uncomfortable design, and compatibility issues with some macOS versions.
    * Note: With only four reviews since its launch last month, **the Apple AirPods product requires a larger sample size before it can be fully considered for analysis**. Otherwise, it would be the worst-performing product, with a 2.3 average rating and -0.38 average sentiment score. Initial sentiment is highly negative, making up 75% of the reviews.
* **The LEGO Toy Set product had an anomalous spike** to 35 reviews in March 2026 before returning to its normal rate of around 10 reviews per month, possibly due to delayed Christmas gift feedback, as ‘Gift Appeal’ and ‘Gift Satisfaction’ were top review topics during this time.
* Top friction topics for all products include product usability, design, quality, and compatibility. These will vary by product, but the technology category, which receives the highest proportion of Mixed and Negative reviews, exhibits most of these flaws.
* 12.6% of reviews, despite maintaining a high positive sentiment (+0.74 average) and overwhelmingly ‘Satisfied’ emotional tone, fall into the lower 1-3 star rating range (2.6 average). The largest point of friction for these reviews is ‘Item Tracking’, suggesting that while the product itself may be praised, external shipping and fulfillment issues drag the rating down.



## Recommendations
* **Investigate the design and compatibility issues for the Apple Magic Mouse**, particularly ensuring that the company website includes comprehensive technical support disclaimers and macOS compatibility guides.
* **Monitor the newly introduced Apple AirPods** for more negative feedback and investigate whether quality control issues exist. It is possible we received a malfunctioning batch.
* Ensure support teams are equipped to handle technical difficulty issues related to connectivity and compatibility.
* **Run post-holiday email campaigns to gather reviews from gift seekers** by targeting holiday buyers in the weeks following Christmas, potentially replicating the post-holiday LEGO Toy Set review spike for other products.
* **Expand the aforementioned compatibility review to all products in the Technology category**, since compatibility remains a primary source of customer friction overall and is occuring most in this category.
* **Improve tracking reliability and delivery visibility** by adding real-time GPS maps, proactive text alerts, and estimated arrival windows to increase customer confidence and mend this point of friction.



# Future Improvements
* Consolidate and standardize main_topic category options to minimize excessive variability.
* Update the pipeline trigger from a daily schedule to event-driven, firing every time a new review row is added to the reviews_raw table.
* Because this project relies on a static dataset on Google Drive & BigQuery rather than live web reviews from a website, implementing a real-time capture webhook was not feasible.
* Store processed data directly in BigQuery to eliminate Google Sheets and Fivetran intermediate steps.
* Integrate a customer support ticket system for urgent cases instead of Slack alerts.
* Implement web scraping for competitor reviews to enable a competitor comparative analysis for the weekly executive summaries.
* Perform demographic analyses by including customer demographic information. However, the current real-world review dataset is anonymized and lacks customer data such as age, gender, and location.
