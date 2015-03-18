# 1. rails_config and settings.yml files

There are a number of files used by the `rails_config` gem - `config/settings.yml`
and all the files under `config/settings/`. These are checked into source
control and should be reviewed to ensure the application functions as you expect. 
They don't contain sensitive information, but have values that are specific to the environment and instance
of the `rocky` application being deployed. See the rocky-settings.md file for an explanation of
all of the options.

The default settings are specified in `config/settings.yml` and environment-specific overides are in
`config/<environment>.yml`.


# 2. Settings keys/values

## `sponsor` settings

The first group specifies values for the default/sponsor partner (partner id = 1)

    sponsor:
      allow_ask_for_volunteers: false
      barcode_prefix: "RTV"
      name: "Rock the Vote"
      url: "http://www.rockthevote.com"
      facebook_callback_url: <%= CGI.escape("http://www.rockthevote.com/register/fb") %>
      footer_link_base_url: "http://www.rockthevote.com/voter-registration/online-application-system"
      footer_copyright: "&copy; Copyright %d, Rock the Vote"
      partner_comarketing_text: |
        Numbers not as high as you'd like?
        <a href="http://www.rockthevote.com/partner/how-to-get-it-out-there.html" target="_blank">Here are some ways to help market your tool.</a>

        
`allow_ask_for_volunteers`

In general, each partner can specify whether the registrant should be prompted to volunteer for the partner and whether to volunteer for the sponsor. When `allow_ask_for_volunteers` is false, the UI never prompts users to volunteer for sponsor regardless of each partner's settings.

`barcode_prefix`

Prefix for the ID content generated as a barcode on the PDFs

`name`

Name of the primary sponsor, used in the partner portal.

`url`

Website for the primary sponsor, used in the footer.

`facebook_callback_url`

Used in the facebook share link.

`footer_link_base_url`

Used in the footer as a prefix for a number of URLs.

`footer_copyright`

Used in the footer.

`partner_comarketing_text`

Displayed in the partner portal statistics page.


## `admin` settings

    admin:
      from_address: "rtv-admins@osuosl.org"
      translation_recipients: "david@rockthevote.com, alex.mekelburg@gmail.com"

`from_address`

The from-email for translations notification emails.

`translation_recipients`

The to-email for translations notification emails.

## Paperclip settings

    paperclip_options: 
      storage: "fog"
      path: ":rails_root/public/system/:attachment/:id/:style/:filename"
      url: "/system/:attachment/:id/:style/:filename"

A hash passed to paperclip's has_attached_file


## State integrations

There are two types of state integrations. "Step 1 Forwarding" and "OVR." 

### Step 1 Forwarding

This is used when minimal data collection is desired. If the zip code provided by a registrant in step 1 matches a state that has it's own online voter registration tool, the user is given the option to go to that site. No data is kept for the user and no data is passed to the state's system in this case. If the user chooses to continue with the `rocky` appliation, then everything else continues as normal

    step_1_forwarding_states:
      VA: https://www.vote.virginia.gov

The `step_1_forwarding_states` key should give a list of key-value pairs of `<two_letter_uppercase_state_abbr>: <full_url_of_state_online_registration_tool>`. States not in the list are considered to not have a step-1-forwarding integration.


### OVR

This is used when registrant data is to be collected for analysis. (Sensitive data like state ID is never kept). 

    ovr_states:
      CA:
        redirect_to_online_reg_url: true
        api_settings:
          api_url: https://covrapitest.sos.ca.gov/PostingEntityInterfaceService.svc
          api_key: d2DE1Nht8I
          api_posting_entity_name: RTV
          debug_in_ui: false
          log_all_requests: false
          disclosures_url: https://a8e83b219df9c88311b3-01fbb794ac405944f26ec8749fe8fe7b.ssl.cf1.rackcdn.com/discl/
          web_url_base: https://covrtest.sos.ca.gov
          web_agency_key: RTV
          custom_error_string: CUSTOM_COVR_ERROR
        languages:
          - en
          - es
          - zh-tw
          - vi
          - ko
          - tl
          - ja
          - hi
          - km
          - th
      NV:
        redirect_to_online_reg_url: true
        languages:
          - en
      WA:
        languages:
          - en

The `ovr_states` key is a list of states (2-letter uppercase abbreviations) and settings for each state. States not in the list are considered to not have an OVR integration. Each state in the list must supply a `languages` setting which should be an array of locale codes for which the integration is valid. Each state can also supply a `redirect_to_online_reg_url` setting. When true this will cause the state's voter registration tool to be opened in a separate tab instead of an iFrame within the `rocky` app. Each state can have a customized integration built in `models/state_customizations/<state>.rb` and further settings for that integration can also be provided here, such the `api_settings` for CA.

## PDF settings

Some settings for the pdf generation content.

    pdf:
      nvra:
        page1:
          default_logo: 'pdf/rtvlogo.gif'
          other_block:
            instructions_url: "http://www.rockthevote.com/registration/instructions/<STATE>-<LOCALE>.html"


`pdf.nvra.page1.default_logo`

Specifes a path to the default logo on the PDFs.

`pdf.nvra.page1.other_block.instructions_url`

URL for voter registration instructions that can have state- and locale-specific values substituted in.


## Partner portal settings

    disable_partner_portal: false
    
`disable_partner_portal`

Turns off the partner portal (redirects to the new registration page).


## Suvery Questions and opt-ins settings

Turn off either of the step 4 sections. If both are turned off, step 4 will be skipped and UI changes should be made to reflect the step number changes.

    disable_survey_questions: false
    disable_opt_ins: false


`disable_survey_questions`

When true, does not display survey questions for sponsor or partner regardless of whether the questions are present.

`disable_opt_ins`

When true, does not display the email, text-message or volunteer opt-ins for either the partner or sponsor.




## Email settings

Settings for emailing registrants.

    disable_email_collection: false
    disable_registrant_emails: false
    hours_before_first_reminder: 120
    hours_between_first_and_second_reminder: 72

`disable_email_collection`

Any link to the new registrant URL can contain the `collectemailaddress=no` parameter which prevents the UI from asking for the user's email address. When `disable_email_collection` is true, the UI will behave as if `collectemailaddress=no` is always passed as a parameter.

`disable_registrant_emails`

When true, prevents any confirmation or reminder emails from being sent to registrants, regardless of whether their email address is collected.

`hours_before_first_reminder`

The number of hours between the registrant PDF being created (and the registrant being notified) and when the first remdiner email should be sent. Since reminder emails are sent via a cron task, this value is a minimum number of hours and not an exact time period.

`hours_between_first_and_second_reminder`

The number of hours between the registrant being sent the first reminder email and when the second remdiner email should be sent. Since reminder emails are sent via a cron task, this value is a minimum number of hours and not an exact time period.

  

## Data retention settings

Settings for retaining PDF and registrant and partner export data.

    pdf_expiration_days: 14
    pdf_no_email_expiration_minutes: 10
    abandoned_registrant_timeout_minutes: 30
    expire_complete_registrants: false
    registrant_expiration_days: 14
    partner_csv_expiration_minutes: 30

`pdf_expiration_days`

Number of *days* after which a PDF should be deleted. This does not need to be an integer, so to specify 1 hour, this setting should be 0.0417. PDFs are only deleted via the `utility:remove_buckets` task which can be scheduled via cron.

`pdf_no_email_expiration_minutes`

Number of *minutes* after which a PDF should be deleted for registrations with no email address.

`abandoned_registrant_timeout_minutes`

Number of *minutes* of inactivity after which an incomplete registration should be removed and marked as abandoned.

`expire_complete_registrants`

If true, and if the `utility:remove_completed_registrants` task is run, will delete completed and abandoned registrants after the `registrant_expiration_days` time has passed. The task can be schedule via cron.

To synchronize registrant and PDF retention, you'll need to set `registrant_expiration_days` equal to `pdf_expiration_days` and make sure the `utility:remove_completed_registrants` and `utility:remove_buckets` tasks are run at the same time (via cron or otherwise).

Note that this `utility:remove_completed_registrants` task is separate from the UI/heroku system's scheduler that runs 'utility:process_ui_records' which deletes completed registrants and submits abandonded registrant data to the CORE system.

`registrant_expiration_days`

Number of *days* after which a completed or abandoned registrant should be deleted. This does not need to be an integer, so to specify 1 hour, this setting should be 0.0417. Registrants are only deleted via the `utility:remove_completed_registrants` task and only if `expire_complete_registrants` is true.


`partner_csv_expiration_minutes`

Number of *minutes* after which a report CSV generated by a partner should be deleted.



## Mobile Settings

Redirect settings for mobile browsers.

    mobile_browsers:
      - mobile
      - webos
      - blackberry
      - iphone
    mobile_redirect_url: https://register2.rockthevote.com

`mobile_browsers`

A list of user agents that should trigger a redirect. When the list is blank, no mobile redirect will happen.

`mobile_redirect_url`

The url to redirect to when a mobile browser is detected.
    
  


## General settings

    from_address: "rocky@example.com"
    default_url_host: "register.example.com"
    ui_url_host: "register5.example.com"
    pdf_host_name: 'vr.rockthevote.com'
    api_host_name: "https://vr.rockthevote.com"
    
    admin_username: 'admin'
    
    widget_loader_url: https://s3.amazonaws.com/ovr/widget_loader.js
    
    use_https: true
    enabled_locales:
      - en
      - es


`from_address`

The from address for emails sent to registrants.

`default_url_host`

Use for action-mailer hostname defaults. Should not include protocol.

`ui_url_host`

URL for the UI system. If a request for the registration UI comes into the CORE system, the user is redirected to the UI system. Should not include the protocol.

`pdf_host_name`

The host name for registrant PDF downloads. Should not include the protocol.

`api_host_name`

The full URL for the CORE system API host - must include the http or https protocol.

`admin_username`

User name for the http basic log-in for the admin portal.

`widget_loader_url`

URL for the javascript widget for partner embed codes

`use_https`

When true, redirect http requests to https.

`enabled_locales`

Array of locale codes that are valid for the user to select in the language picker. May be different from the list in  `config.i18n.available_locales` in `application.rb`.

  
  
