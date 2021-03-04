# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    Movie.create(movie)
  end
end

Then /(.*) seed movies should exist/ do | n_seeds |
  Movie.count.should be n_seeds.to_i
end

# Get the content from index 
# Get the sorted order from db 
# Compare each corresponding pair in the 2 lists
Then /I should see movies sorted in increasing order of (.*)/ do |sort_by|
  rows = page.all('#movies tbody tr')
  movies = Movie.select('title').order(sort_by.parameterize.underscore)
  rows.zip(movies).each do |row, movie|
    expect(row.text).to have_text movie[:title]
  end
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
  rows.should be Movie.count
end
