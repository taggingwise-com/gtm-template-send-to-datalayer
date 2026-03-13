___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Send to dataLayer",
  "brand": {
    "id": "taggingwise_com",
    "displayName": "taggingwise.com"
  },
  "description": "",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "event_to_send",
    "displayName": "Event name (consider using snake_case)",
    "simpleValueType": true,
    "alwaysInSummary": true
  },
  {
    "type": "SIMPLE_TABLE",
    "name": "sub_params",
    "displayName": "Event Parameters",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "Parameter Key",
        "name": "paramKey",
        "type": "TEXT"
      },
      {
        "defaultValue": "",
        "displayName": "Parameter Value",
        "name": "paramValue",
        "type": "TEXT"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const dataLayerPush = require('createQueue')('dataLayer');
const eventData = {
  event: data.event_to_send
};

// Add sub parameters if they exist
if (data.sub_params && data.sub_params.length > 0) {
  data.sub_params.forEach(param => {
    if (param.paramKey && param.paramValue) {
      eventData[param.paramKey] = param.paramValue;
    }
  });
}

dataLayerPush(eventData);

// Call data.gtmOnSuccess when the tag is finished.
data.gtmOnSuccess();


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "dataLayer"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 28.5.2025, 14.24.54


