# How to Get a New Algolia MCP Server URL

## ✅ Good News!
Your test script is now working and you have API requests left!

## The Issue
Your current MCP URL token has expired (returning 500 errors). You need to generate a new one.

## Steps to Get New MCP URL

### Method 1: Through Algolia Dashboard (Recommended)

1. **Log into Algolia Dashboard**
   - Go to: https://dashboard.algolia.com/
   - Sign in with your Algolia account

2. **Navigate to AI/MCP Settings**
   
   The MCP Server settings might be in one of these locations:
   
   - **Option A**: Left sidebar → "AI" or "AI Features" or "Algolia AI"
   - **Option B**: Top menu → "Tools" → "MCP Server"
   - **Option C**: Left sidebar → "Settings" → "MCP" or "Integrations"
   - **Option D**: Application settings (gear icon) → "MCP Server"
   
   Look for sections mentioning:
   - "MCP Server"
   - "Model Context Protocol"
   - "LLM Integration"
   - "AI Connectors"

3. **Create New MCP Server Instance**
   
   You should see an option to:
   - "Create MCP Server"
   - "Generate MCP URL"
   - "Add MCP Instance"
   
   When creating:
   - **Select your application**: MHB695BBRR
   - **Select indices**: Choose your "Event" or "Events" index
   - **Region**: Should auto-select based on your app (probably "us")

4. **Copy the Generated URL**
   
   The URL format will be:
   ```
   https://mcp.us.algolia.com/1/{UNIQUE_TOKEN_HERE}/mcp
   ```
   
   Copy this entire URL.

5. **Update Your .env File**
   
   Replace line 7 in your `.env` file:
   
   ```bash
   ALGOLIA_MCP_URL=https://mcp.us.algolia.com/1/YOUR_NEW_TOKEN/mcp
   ```

6. **Test the Connection**
   
   From WSL:
   ```bash
   cd /mnt/c/Users/Anna/Desktop/Codestuff/go-vend-event
   ruby scripts/test_mcp_connection.rb
   ```
   
   You should see:
   ```
   ✅ Initialize: SUCCESS
   ✅ Session initialized successfully
   ```

### Method 2: Contact Algolia Support

If you can't find the MCP Server settings in the dashboard:

**Email:** support@algolia.com

**Subject:** Need Help Creating Algolia MCP Server Instance

**Body:**
```
Hi Algolia Team,

I'm working on a project that uses Algolia's MCP (Model Context Protocol) 
Server with a local LLM (Ollama). My current MCP URL token has expired.

Could you please help me:
1. Generate a new MCP Server URL for my application
2. Or point me to where I can create one in the dashboard

Application ID: MHB695BBRR
Index: Event (or Events - whichever you have)
Region: US

Thank you!
```

### Method 3: Use Algolia API to Create MCP Instance (Advanced)

If Algolia provides an API endpoint for creating MCP servers, you could use:

```bash
curl -X POST \
  https://api.algolia.com/1/mcp/instances \
  -H "X-Algolia-Application-Id: MHB695BBRR" \
  -H "X-Algolia-API-Key: YOUR_ADMIN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "indices": ["Event"],
    "region": "us"
  }'
```

**Note:** This endpoint might not exist - check Algolia's API documentation first.

## What If You Can't Find MCP Settings?

### Possibility 1: Feature Not Available on Your Plan

MCP Server might be:
- A beta feature requiring special access
- Only available on certain Algolia plans
- Requires manual enablement by Algolia

**Solution:** Email support@algolia.com and ask them to enable it

### Possibility 2: Use Alternative Algolia Integration

Even without MCP, you can still use Algolia for your challenge:

**Configure Algolia Search in Event Model:**

```ruby
# app/models/event.rb
class Event < ApplicationRecord
  include AlgoliaSearch
  
  algoliasearch do
    attributes :name, :city, :state, :address, :started_at
    
    searchableAttributes [
      'name',
      'city',
      'state',
      'address'
    ]
    
    customRanking [
      'desc(started_at)'
    ]
  end
end
```

**Then reindex:**
```bash
rails console
Event.reindex
```

**Use in your service:**
```ruby
# app/services/algolia_search_service.rb
results = Event.search(user_query, hitsPerPage: 10)
```

This uses Algolia's regular API (not MCP) and still counts toward your challenge!

## Troubleshooting

### "I logged in but don't see MCP anywhere"

**Try:**
1. Check if there's a search bar in the dashboard - search for "MCP" or "Model Context Protocol"
2. Look in account/billing settings - MCP might need to be enabled
3. Check "Integrations" or "Connectors" section
4. Email support - they can point you to it

### "MCP Server option is grayed out"

**Likely reasons:**
- Need to upgrade plan
- Need to add payment method
- Need to verify email/account

**Solution:** Contact support

### "I created MCP URL but it still returns 500"

**Possible issues:**
1. Token not activated yet (wait 5-10 minutes)
2. Index name mismatch - make sure you selected correct index
3. Region mismatch - make sure region matches your app

**Debug:**
```bash
# Check what's in your Algolia index
rails console
Event.search("*").count  # Should show number of records
```

## After Getting New URL

1. **Update .env**
   ```bash
   ALGOLIA_MCP_URL=https://mcp.us.algolia.com/1/NEW_TOKEN/mcp
   ```

2. **Restart Rails server**
   ```bash
   # Stop current server (Ctrl+C)
   rails server
   ```

3. **Test MCP connection**
   ```bash
   ruby scripts/test_mcp_connection.rb
   ```

4. **Test the chat**
   - Open http://localhost:3000
   - Try: "Find events in Chicago"
   - Check logs for:
     ```
     ✅ MCP session initialized successfully
     📞 Calling tool: algolia_search_index_Event
     ```

## Success Indicators

When MCP is working, your logs will show:
```
🎯 User Query: Find events in Chicago
📡 Connecting to Algolia MCP server...
✅ MCP session initialized successfully
🔧 Available tools: 1 tools found
🔨 Tool names: algolia_search_index_Event
📞 Calling tool: algolia_search_index_Event
📦 Tool result: {...}
```

## Need Help?

If you're stuck:
1. Send a screenshot of your Algolia dashboard to support
2. Mention you're looking for "MCP Server" or "Model Context Protocol" settings
3. Reference their documentation: https://www.algolia.com/doc/guides/algolia-ai/mcp-server/

You've got API requests - you just need that MCP URL! 🚀
