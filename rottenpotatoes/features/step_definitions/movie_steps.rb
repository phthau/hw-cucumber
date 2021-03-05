# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    Movie.create(movie)
  end
end

Then /(.*) seed movies should exist/ do | n_seeds |
  expect(Movie.count).to be n_seeds.to_i
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  rating_list = rating_list.split(", ")
  rating_list.each do |rating|
    step %{I #{uncheck}check "ratings[#{rating}]"}
  end
end

# Using regex to search for one string before another 
Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  expect(page.body).to match /#{e1}.*#{e2}/m
end


Then /I should (not )?see movies of the following ratings: (.*)/ do |invisible, rating_list|
  rating_list = rating_list.split(", ")
  movies = Movie.select('title').where(rating: rating_list)
  if invisible
    movies.each do |movie|
      expect(page).to have_no_content(movie[:title])
    end
  else 
    movies.each do |movie|
      expect(page).to have_content(movie[:title])
    end
  end
end

Then /I should see all the movies/ do
  rows = page.all("#movies tbody tr").count
  expect(rows).to be Movie.count
end
