For API registration calls to work correctly the value of `pdf_hostname` (see
config/settings.yml and config/settings/<env>.yml) should be set to the host
name of the server that has to be put in the PDF URLs.

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

## `sponsor`

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

    barcode_prefix

Prefix for the ID content generated as a barcode on the PDFs

### `name`

Name of the primary sponsor, used in the partner portal.

### `url`

Website for the primary sponsor, used in the footer.

### `facebook_callback_url`

Used in the facebook share link.

### `footer_link_base_url`

Used in the footer as a prefix for a number of URLs.

### `footer_copyright`

Used in the footer.

### `partner_comarketing_text`

Displayed in the partner portal statistics page.

## `disable_survey_questions`

When true, does not display survey questions for sponsor or partner regardless of whether the questions are present.

## `disable_opt_ins`

When true, does not display the email, text-message or volunteer opt-ins for either the partner or



disable_partner_portal: false

from_address: "rocky@example.com"
default_url_host: "register.example.com"
ui_url_host: "register5.example.com"
pdf_host_name: 'vr.rockthevote.com'
api_host_name: "https://vr.rockthevote.com"


admin:
  from_address: "rtv-admins@osuosl.org"
  translation_recipients: "david@rockthevote.com, alex.mekelburg@gmail.com"

admin_username: 'admin'
widget_js_url:  'https://s3.amazonaws.com/ovr/widget_loader.js'

use_https: true
paperclip_options: 
  storage: "fog"
  path: ":rails_root/public/system/:attachment/:id/:style/:filename"
  url: "/system/:attachment/:id/:style/:filename"

mobile_redirect_url: https://register2.rockthevote.com
mobile_browsers:
  - mobile
  - webos
  - blackberry
  - iphone
  
widget_loader_url: https://s3.amazonaws.com/ovr/widget_loader.js
hours_before_first_reminder: 120
hours_between_first_and_second_reminder: 72
pdf_expiration_days: 14

abandoned_registrant_timeout_minutes: 30
expire_complete_registrants: false
registrant_expiration_days: 14

pdf_no_email_expiration_minutes: 10
partner_csv_expiration_minutes: 30

disable_email_collection: false
disable_registrant_emails: false
  

# step_1_forwarding_states:
#     VA: https://www.vote.virginia.gov

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

  
enabled_locales:
  - en
  - es


  

pdf:
  nvra:
    page1:
      default_logo: 'pdf/rtvlogo.gif'
      other_block:
        instructions_url: "http://www.rockthevote.com/registration/instructions/<STATE>-<LOCALE>.html"
  
