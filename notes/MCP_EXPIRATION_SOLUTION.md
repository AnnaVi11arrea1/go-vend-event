# Why Your MCP URLs Keep Expiring (And What To Do About It)

## The Problem

You're on Algolia's **free tier**, and MCP Server URLs appear to have **short expiration times** (24-48 hours). This is likely intentional for free tier users.

**This is NOT sustainable for a challenge project!** You can't keep creating new MCP instances every day or two.

## Why This Happens

Free tier MCP URLs likely expire quickly to:
- Prevent abuse of free resources
- Encourage upgrades to paid plans
- Limit long-term free usage

## Solution Options (Ranked Best to Worst)

### ⭐ Option 1: Use Regular Algolia API (RECOMMENDED)

**Why this is better:**
- Uses your existing API request quota
- No token expiration issues
- Still counts as "using Algolia" for your challenge
- More stable and production-ready

**Implementation:**

1. **Configure Algolia Search in Event Model**

```ruby
# app/models/event.rb
class Event < ApplicationRecord
  include AlgoliaSearch
  
  algoliasearch do
    # Define which fields to index
    attributes :name, :city, :state, :address, :started_at, :latitude, :longitude
    
    # Fields to search in (prioritized order)
    searchableAttributes [
      'unordered(name)',     # Higher priority
      'unordered(city)',
      'unordered(state)',
      'address'
    ]
    
    # Custom ranking criteria
    customRanking [
      'desc(started_at)'     # Prefer upcoming events
    ]
    
    # Attributes for filtering
    attributesForFaceting [
      'city',
      'state'
    ]
  end
end
```

2. **Reindex Your Data** (one-time operation)

```bash
rails console
Event.reindex  # This sends all events to Algolia
```

3. **Update Your Search Service**

```ruby
# app/services/algolia_search_service.rb
def search_with_direct_algolia(user_query, &block)
  Rails.logger.info("🔍 Using Algolia regular API")
  
  # Extract location from query
  location = extract_location_keywords(user_query)
  
  # Build search options
  options = {
    hitsPerPage: 10,
    attributesToRetrieve: ['name', 'city', 'state', 'address', 'started_at', 'objectID']
  }
  
  # Add location filter if found
  if location.present?
    options[:filters] = "city:#{location} OR state:#{location}"
  end
  
  begin
    # Use Algolia's regular search API
    results = Event.search(user_query, options)
    
    if results.empty?
      return "I couldn't find any events matching your search. Try a different location!"
    end
    
    # Format results for Ollama
    events_context = results.map do |event|
      {
        objectID: event.id,
        name: event.name,
        address: event.address,
        city: event.city,
        state: event.state,
        date: event.started_at&.strftime('%B %d, %Y') || 'Date TBD'
      }
    end
    
    # Let Ollama format the results nicely
    system_prompt = <<~PROMPT
      You are a helpful assistant. The user asked: "#{user_query}"
      
      Here are #{results.count} events from Algolia search:
      #{events_context.to_json}
      
      Format these events using markdown with numbered lists, 
      bullet points, and clickable links: 
      [View Event Details](https://govend.ing/events/[objectID])
    PROMPT
    
    response = call_ollama_chat(
      model: 'llama3.2',
      messages: [
        { role: 'system', content: system_prompt },
        { role: 'user', content: "Please format these events" }
      ]
    )
    
    response.dig('message', 'content')
    
  rescue StandardError => e
    Rails.logger.error("❌ Algolia search error: #{e.message}")
    "Sorry, I encountered an error searching for events."
  end
end
```

4. **Update Your Main Service Flow**

```ruby
# app/services/algolia_search_service.rb
def ask(user_query, &block)
  Rails.logger.info("🎯 User Query: #{user_query}")
  
  # Skip MCP entirely - go straight to Algolia regular API
  return search_with_direct_algolia(user_query, &block)
end
```

**Result:** 
- ✅ Uses Algolia (counts for challenge)
- ✅ No MCP token expiration
- ✅ Ollama still formats results
- ✅ Uses your existing API quota
- ✅ More stable and reliable

---

### Option 2: MCP Token Auto-Refresh (Complex, Not Recommended)

**Theory:** Build automatic MCP token refresh logic

**Problems:**
- Algolia might not provide an API to generate MCP tokens programmatically
- Would need to scrape dashboard or automate browser
- Still hitting free tier limits
- Fragile and hacky

**Verdict:** Not worth the effort

---

### Option 3: Upgrade Algolia Plan

**Cost:** Depends on plan, likely $1-50/month

**Benefits:**
- Longer MCP token lifetimes (maybe permanent?)
- More API requests
- Better support

**For a challenge:** Probably overkill unless you have budget

---

### Option 4: Accept Short-Lived MCP Tokens

**Strategy:** 
- Update MCP URL daily/every 2 days
- Use fallback mode when MCP expires
- Generate new token before demos

**Problems:**
- Annoying maintenance
- Might expire during demo
- Not professional

---

## My Strong Recommendation: Use Option 1

**Switch from MCP to Regular Algolia API because:**

1. **More Stable** - No expiring tokens
2. **Still "Algolia"** - Counts for your challenge
3. **Better Practice** - Regular API is what most apps use
4. **Your Unique Angle** - Ollama integration is still your differentiator
5. **Production Ready** - This is how real apps work

**For your challenge presentation:**
- "I use Algolia's Search API with custom LLM integration"
- "Integrated Ollama for natural language query processing"
- "Explored Algolia's MCP Server but opted for regular API for stability"
- "Demonstrates production-ready Algolia integration"

## Implementation Steps (15 minutes)

1. **Update Event model** (see code above)
2. **Reindex** (`Event.reindex` in console)
3. **Update search service** (see code above)
4. **Test** with `rails server` and try chat
5. **Done!** No more token expiration issues

## The Bottom Line

**Stop fighting with MCP token expiration!** 

The regular Algolia API:
- ✅ Solves your problem
- ✅ Still impressive for challenge
- ✅ More stable
- ✅ Still uses Ollama (your differentiator)
- ✅ Is what production apps actually use

MCP is cool, but if the tokens expire every 1-2 days on free tier, it's not worth the hassle for a challenge project.

Want me to help you implement Option 1? It'll take 15 minutes and solve this forever.
