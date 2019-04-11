Feed The Bot
==========

Perhaps the dumbest idea I've ever had.


Google AI Platform - Online Labeling Services
---

https://cloud.google.com/data-labeling/docs/instructions


Designing good instructions

Good instructions are the most important factor in getting good human labeling results. Since you know your use case best, you need to let the human labelers know what you want them to do. Here are some guidelines for creating good instructions:

Remember that the human labelers don't have your domain knowledge. The distinctions you ask labelers to make should be easy to understand for someone unfamiliar with your use case.
Don't make the instructions too long. It's best if an labeler can review and understand them within 20 minutes.
Instructions should describe the concept of the task as well as details about how to label the data. For example, for a bounding box task, describe how you want labelers to draw the bounding box. Should it be a tight box or loose box? If there are multiple instances of the object should they draw a big bounding box or multiple smaller ones?
Your instructions should cover all labels in the annotation specification set. The label name in the instructions should match the name in the annotation specification set.
Include both positive and negative examples for each potential situation.
Describe all edge cases that you can think of. For example, should the labeler label an image as "dog" if it shows only part of the dog?
It often takes several iterations to create good instructions. We recommend having a small dataset labeled first, then adjust your instructions based on what you see in the results you get back.


