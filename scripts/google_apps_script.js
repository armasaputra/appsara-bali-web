/**
 * =========================================================================
 * APPSARA BALI - GOOGLE APPS SCRIPT LEADERBOARD API
 * =========================================================================
 * Instructions:
 * 1. Open your Google Sheet (e.g. named "Leaderboard Appsara Bali").
 * 2. In Sheet1, put the header row:
 *    Column A: Name | Column B: Stars | Column C: LastUpdated
 * 3. Go to Extensions > Apps Script (or https://script.new).
 * 4. Paste this entire code into Code.gs.
 * 5. (Optional): If created via script.new, fill in SPREADSHEET_ID below.
 * 6. Click "Deploy" > "Manage deployments" > Edit (pencil icon) > Version: "New version" > Click "Deploy".
 * =========================================================================
 */

// OPTIONAL: If your script is created outside the sheet, paste the ID from your sheet URL here:
var SPREADSHEET_ID = "";

function getLeaderboardSheet() {
  if (SPREADSHEET_ID && SPREADSHEET_ID.trim() !== "") {
    return SpreadsheetApp.openById(SPREADSHEET_ID.trim()).getActiveSheet();
  }
  return SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
}

function doGet(e) {
  try {
    var sheet = getLeaderboardSheet();
    var data = sheet.getDataRange().getValues();
    
    // Check if score update or player rename was requested
    if (e && e.parameter && (e.parameter.name || e.parameter.old_name)) {
      var newName = e.parameter.name ? String(e.parameter.name).trim() : "";
      var oldName = e.parameter.old_name ? String(e.parameter.old_name).trim() : "";
      var playerStars = e.parameter.stars !== undefined ? (Number(e.parameter.stars) || 0) : null;
      
      var targetSearch = oldName !== "" ? oldName : newName;
      var foundRowIndex = -1;
      
      // Look for existing row by oldName or newName
      for (var i = 1; i < data.length; i++) {
        var rowName = String(data[i][0]).trim().toLowerCase();
        if (targetSearch !== "" && rowName === targetSearch.toLowerCase()) {
          foundRowIndex = i + 1;
          break;
        }
      }
      
      // If oldName was specified but not found, try searching by newName
      if (foundRowIndex < 0 && newName !== "") {
        for (var i = 1; i < data.length; i++) {
          var rowName = String(data[i][0]).trim().toLowerCase();
          if (rowName === newName.toLowerCase()) {
            foundRowIndex = i + 1;
            break;
          }
        }
      }
      
      if (foundRowIndex > 0) {
        // Rename row if name changed
        if (newName !== "") {
          sheet.getRange(foundRowIndex, 1).setValue(newName);
        }
        // Update star count
        if (playerStars !== null) {
          var currentStars = Number(data[foundRowIndex - 1][1]) || 0;
          if (playerStars >= currentStars || oldName !== "") {
            sheet.getRange(foundRowIndex, 2).setValue(playerStars);
            sheet.getRange(foundRowIndex, 3).setValue(new Date().toISOString());
          }
        }
      } else if (newName !== "") {
        // Append new player record
        sheet.appendRow([newName, playerStars !== null ? playerStars : 0, new Date().toISOString()]);
      }
      
      // Refresh data array after modification
      data = sheet.getDataRange().getValues();
    }
    
    var leaderboard = [];
    for (var i = 1; i < data.length; i++) {
      var name = data[i][0];
      var stars = Number(data[i][1]) || 0;
      if (name && String(name).trim() !== "") {
        leaderboard.push({
          name: String(name).trim(),
          stars: stars
        });
      }
    }
    
    // Sort descending by stars
    leaderboard.sort(function(a, b) {
      return b.stars - a.stars;
    });
    
    return ContentService.createTextOutput(JSON.stringify({
      status: "success",
      data: leaderboard
    })).setMimeType(ContentService.MimeType.JSON);
    
  } catch (err) {
    return ContentService.createTextOutput(JSON.stringify({
      status: "error",
      message: err.toString()
    })).setMimeType(ContentService.MimeType.JSON);
  }
}

function doPost(e) {
  return doGet(e);
}
