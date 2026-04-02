const axios = require('axios');
const fs = require('fs');
const path = require('path');

const subscriptionsFile = path.join(__dirname, 'subscriptions.json');
if (!fs.existsSync(subscriptionsFile)) {
  console.log('No subscriptions file found.');
  process.exit(0);
}

const data = JSON.parse(fs.readFileSync(subscriptionsFile, 'utf8'));
const subscriptions = data.subscriptions || data;

const emailTo = process.env.EMAIL_TO;
const apiKey = process.env.BREVO_API_KEY;

if (!emailTo || !apiKey) {
  console.log('Missing EMAIL_TO or BREVO_API_KEY');
  process.exit(0);
}

const today = new Date();
const remindDays = [1, 3, 7, 14];

const upcoming = subscriptions
  .filter(sub => !sub.isCancelled)
  .map(sub => {
    const days = Math.ceil((new Date(sub.renewal_date) - today) / (1000 * 60 * 60 * 24));
    return { ...sub, days };
  })
  .filter(sub => remindDays.includes(sub.days));

if (!upcoming.length) {
  console.log('No reminders needed today!');
  process.exit(0);
}

const total = upcoming.reduce((sum, s) => sum + s.amount, 0).toFixed(2);

let htmlContent = `<html><body style="font-family: Arial; max-width: 600px; margin: 0 auto;">
<h2 style="color: #e53935;">📋 SubKiller Reminder</h2>
<p>You have <strong>${upcoming.length}</strong> subscription(s) renewing soon:</p>
<table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
<tr style="background: #f5f5f5;"><th style="padding: 12px; text-align: left;">Service</th><th style="padding: 12px; text-align: left;">Amount</th><th style="padding: 12px; text-align: left;">Renews</th></tr>`;

upcoming.forEach(sub => {
  htmlContent += `<tr><td style="padding: 12px; border: 1px solid #ddd;">${sub.name}</td><td style="padding: 12px; border: 1px solid #ddd;">$${sub.amount.toFixed(2)}</td><td style="padding: 12px; border: 1px solid #ddd; color: ${sub.days <= 3 ? '#e53935' : '#666'};">${sub.days} days</td></tr>`;
});

htmlContent += `</table><p style="font-size: 18px;"><strong>Total: $${total}</strong></p></body></html>`;

async function sendEmail() {
  try {
    await axios.post('https://api.brevo.com/v3/smtp/email', {
      sender: { name: 'SubKiller', email: 'noreply@subkiller.app' },
      to: [{ email: emailTo }],
      subject: `🔔 SubKiller: ${upcoming.length} subscription(s) renewing!`,
      htmlContent: htmlContent
    }, { headers: { 'api-key': apiKey, 'Content-Type': 'application/json' } });
    
    console.log('✅ Email sent!');
    console.log('📧 Reminders: ' + upcoming.map(s => s.name).join(', '));
  } catch (err) {
    console.error('❌ Error:', err.response?.data || err.message);
    process.exit(1);
  }
}

sendEmail();
