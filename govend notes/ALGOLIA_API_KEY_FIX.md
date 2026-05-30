# ✅ FIXED: Algolia API Key Permissions

## The Problem

You were getting:
```
403: Method not allowed with this API key
```

**Cause:** Your `ALGOLIA_API_KEY` was set to the **Search key** (read-only), but indexing requires the **Write key** (read+write).

## What I Fixed

Changed your `.env` file:

**Before:**
```bash
ALGOLIA_API_KEY=5e35c8b0017e2cb6d22af3c79eee939e  # ❌ Search key (read-only)
```

**After:**
```bash
ALGOLIA_API_KEY=0edd29d253792336aa1889299b70b272  # ✅ Write key (read+write)
```

## What You Need To Do Now

### Step 1: Restart Rails Console

```bash
# Exit current console
exit

# Start new console (to load new .env)
rails console
```

### Step 2: Try Reindex Again

```ruby
# This should work now!
Event.reindex
```

**Expected output:**
```
Indexed 50 records  # (or however many events you have)
```

### Step 3: Verify It Worked

```ruby
# Test search
Event.search("*").count
# Should return: number of events

# Try specific search
Event.search("Chicago")
# Should return: Chicago events
```

### Step 4: Restart Rails Server

```bash
# Exit console
exit

# Restart server
rails server
```

### Step 5: Test Your Chat

1. Open http://localhost:3000
2. Try: "Find events in Chicago"
3. Should work perfectly!

## Understanding Algolia API Keys

You have 3 different keys:

1. **Search Key** (`ALGOLIA_SEARCH_KEY`)
   - Read-only
   - Can only search/read data
   - Safe to use in frontend JavaScript
   - **Don't use for indexing!**

2. **Write Key** (`ALGOLIA_WRITE_KEY` / `ALGOLIA_API_KEY`)
   - Read + Write permissions
   - Can index, update, delete records
   - **Use for backend operations**
   - Keep secret!

3. **Admin Key** (you might have this too)
   - Full access to everything
   - Can manage settings, indices, keys
   - Most powerful, most dangerous
   - Only use when absolutely needed

## What's Configured Now

```bash
# Backend uses WRITE key (for indexing/searching)
ALGOLIA_API_KEY=0edd29d253792336aa1889299b70b272  # Write key ✅

# Frontend could use SEARCH key (for read-only searches)
ALGOLIA_SEARCH_KEY=5e35c8b0017e2cb6d22af3c79eee939e  # Search key
```

## Troubleshooting

### Still Getting 403 Error?

1. **Verify key in console:**
   ```ruby
   ENV['ALGOLIA_API_KEY']
   # Should show: 0edd29d253792336aa1889299b70b272
   ```

2. **If it shows the OLD key (5e35c8...):**
   - You need to restart Rails console
   - Exit and run `rails console` again

3. **Check if key is valid:**
   - Visit: https://dashboard.algolia.com/account/api-keys
   - Verify the Write key is: 0edd29d253792336aa1889299b70b272
   - Make sure it's not revoked/expired

### Getting Different Error?

**Rate limit error:**
```
429: Too many requests
```
- Wait a few minutes
- Try smaller batch: `Event.limit(10).reindex`

**Authentication error:**
```
401: Invalid credentials
```
- Check `ALGOLIA_APP_ID` is correct: MHB695BBRR
- Check key isn't expired

## Next Steps

Once reindex works:

1. ✅ Events are in Algolia
2. ✅ Your chat will use Algolia API
3. ✅ No more MCP token expiration issues
4. ✅ Ready to demo!

## The Bottom Line

**You needed the Write key, not the Search key!** 

Now it's fixed - just restart Rails console and run `Event.reindex` again! 🚀
