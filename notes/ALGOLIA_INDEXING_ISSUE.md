# 🔴 Only 20 Events Indexed (Should Be Thousands)

## The Problem

Reindex appeared to run, but only 20 out of ~11,000 events made it to Algolia.

## Possible Causes

1. **API Key Restrictions** - Write key might have limits
2. **Rate Limiting** - Free tier might restrict bulk indexing
3. **Missing Required Fields** - Events without required data rejected
4. **Index Size Limits** - Free tier might cap total records

## Diagnostic Steps

### Step 1: Check Which Events Got Indexed

```ruby
# Get the 20 events that ARE in Algolia
indexed_events = Event.search("*", hitsPerPage: 20)
indexed_ids = indexed_events.map(&:id)

puts "Indexed event IDs: #{indexed_ids.inspect}"

# Check what's special about these events
indexed_events.first.inspect
```

### Step 2: Compare with Non-Indexed Events

```ruby
# Get an event that DIDN'T get indexed
non_indexed = Event.where.not(id: indexed_ids).first

puts "=== INDEXED EVENT ==="
indexed_events.first.attributes.inspect

puts "\n=== NON-INDEXED EVENT ==="
non_indexed.attributes.inspect
```

Look for differences in:
- Missing fields (nil values)
- Data format issues
- Required fields

### Step 3: Check Free Tier Limits

Your Algolia free tier might have:
- **10,000 records per index limit** (common)
- **100,000 operations per month limit**
- **1MB index size limit** (unlikely)

**Check your dashboard:**
https://dashboard.algolia.com/account/usage

Look for:
- Current record count
- Index size
- Any warnings/errors

### Step 4: Try Manual Index of One Event

```ruby
# Pick an event that's NOT in the 20
test_event = Event.where.not(id: indexed_ids).first

# Try to index it manually
begin
  test_event.index!
  puts "✅ Successfully indexed event #{test_event.id}"
  
  # Verify it's searchable
  sleep(2)  # Give Algolia time to process
  results = Event.search(test_event.name)
  if results.any?
    puts "✅ Event is now searchable"
  else
    puts "⚠️ Event indexed but not searchable yet (wait a bit)"
  end
rescue => e
  puts "❌ Failed to index: #{e.message}"
  puts "Error class: #{e.class}"
end
```

## Quick Fixes to Try

### Fix 1: Reindex with Error Handling

```ruby
# This will show which events fail
failed_events = []
success_count = 0

Event.find_each do |event|
  begin
    event.index!
    success_count += 1
    print "." if success_count % 100 == 0
  rescue => e
    failed_events << { id: event.id, error: e.message }
  end
end

puts "\n✅ Successfully indexed: #{success_count}"
puts "❌ Failed: #{failed_events.count}"

if failed_events.any?
  puts "\nFirst 5 failures:"
  failed_events.first(5).each do |f|
    puts "  Event #{f[:id]}: #{f[:error]}"
  end
end
```

### Fix 2: Check for Missing Required Fields

```ruby
# Find events with missing critical fields
problematic = Event.where(name: nil)
                   .or(Event.where(city: nil))
                   .or(Event.where(state: nil))
                   .count

puts "Events with missing required fields: #{problematic}"

# If many have missing fields, that's the issue
```

### Fix 3: Clear Index and Reindex Fresh

```ruby
# CAUTION: This deletes the Algolia index
Event.clear_index!

# Wait a moment
sleep(2)

# Reindex (try first 100 to test)
Event.limit(100).reindex

# Check count
sleep(2)
Event.search("*").count
# Should return 100 (or close to it)
```

## Most Likely Cause: Free Tier Limits

Algolia free tier typically allows:
- ✅ 10,000 records total
- ✅ 100,000 search operations/month
- ❌ But might have **batch indexing restrictions**

**The 20 records might be from a previous test**, and bulk reindex is being silently rejected.

## Recommended Solution

### Option A: Contact Algolia Support (Best for Challenge)

Email: support@algolia.com

```
Subject: Bulk Reindex Not Working on Free Tier

Hi Algolia Team,

I'm working on a challenge project and need to index ~11,000 events. 
When I run Event.reindex, only 20 records appear in Algolia.

Could you please:
1. Check if my account has bulk indexing restrictions
2. Temporarily increase limits for this challenge project

App ID: MHB695BBRR
Index: Event

Thank you!
```

### Option B: Index in Small Batches with Delays

```ruby
# Index 1000 at a time with pauses
total = Event.count
batch_size = 1000
batches = (total / batch_size.to_f).ceil

puts "Indexing #{total} events in #{batches} batches..."

Event.find_in_batches(batch_size: batch_size).with_index do |batch, i|
  Event.index!(batch)
  indexed_so_far = (i + 1) * batch_size
  puts "Batch #{i + 1}/#{batches} complete (#{indexed_so_far}/#{total})"
  sleep(5)  # Wait 5 seconds between batches
end

puts "\nDone! Checking count..."
sleep(5)
puts "Algolia count: #{Event.search('*').count}"
```

### Option C: Index Only Important Events

If you just need a demo:

```ruby
# Index only upcoming events
Event.where("started_at >= ?", Date.today).reindex

# Check count
Event.search("*").count
```

## Next Steps

1. **Run Step 4 above** (manual index test) to see the actual error
2. **Check dashboard** for limits/warnings
3. **Try Fix 2** to see if it's a batch limit issue
4. **Email Algolia** if free tier has restrictions

Let me know what the manual index test (`test_event.index!`) returns!
