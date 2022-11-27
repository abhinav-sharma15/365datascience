-- master table
-- Student status is considered 'paid' if they have ever paid for the subscription and 'free' otherwise
select a.student_id
, a.student_country
, a.date_registered
, coalesce(min(b.date_purchased), null) as first_date_purchased
, ifnull(c.minutes_watched, 0) as mins_watched_14d
, ifnull(d.quiz_engagements, 0) as quiz_engagements_14d
, ifnull(d.exams_engagements, 0) as exams_engagements_14d
, ifnull(d.lessons_engagements, 0) as lessons_engagements_14d
, ifnull(e.avg_course_ratings,0) as course_ratings_14d
, ifnull(f.hub_ques_asked,0) as hub_questions_14d
, case when isnull(b.date_purchased) then 0
else 1
end as reg_status
from 365_student_info a
left join 365_student_purchases b
on a.student_id = b.student_id
left join (select a.student_id, sum(b.minutes_watched) as minutes_watched
from 365_student_info a
left join 365_student_learning b
on a.student_id = b.student_id
where b.date_watched <= Adddate(a.date_registered, 14)
group by 1) c
on a.student_id = c.student_id
left join (select a.student_id, sum(b.engagement_quizzes) as quiz_engagements
		, sum(b.engagement_exams) as exams_engagements, sum(b.engagement_lessons) as lessons_engagements
        from 365_student_info a
        left join 365_student_engagement b
        on a.student_id = b.student_id
        where b.date_engaged <= Adddate(a.date_registered, 14)
        group by 1) as d
on a.student_id = d.student_id
left join (select a.student_id, avg(b.course_rating) as avg_course_ratings
			from 365_student_info a
            left join 365_course_ratings b
            on a.student_id = b.student_id
            where b.date_rated <= Adddate(a.date_registered, 14)
            group by 1) e
on a.student_id = e.student_id
left join (select a.student_id, count(b.date_question_asked) as hub_ques_asked
			from 365_student_info a
            left join 365_student_hub_questions b
            on a.student_id = b.student_id
            where b.date_question_asked <= Adddate(a.date_registered, 14)
            group by 1) f
on a.student_id = f.student_id             
group by 1;
