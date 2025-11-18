-- 1. Create 500 places (meets "hundreds" requirement) 
sp_populate_place(500);

-- 2. Create 2,000 users (meets "thousands" requirement 1) 
sp_populate_user(2000);

-- 3. Create 1,500 events (meets "thousands" requirement 2) 
sp_populate_event(1500);

-- 4. Create 5,000 visits (to connect users and events)
sp_populate_visits(5000);

-- 5. Create 1,000 reviews
sp_populate_reviews(1000);