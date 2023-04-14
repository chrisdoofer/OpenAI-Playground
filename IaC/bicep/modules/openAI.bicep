@description('The name for your OpenAI account resource.')
param openaiAccName string 
param location string
param sku string

resource open_ai 'Microsoft.CognitiveServices/accounts@2022-03-01' = {
  name: openaiAccName  
  location: location
  kind: 'OpenAI'
  sku: {
    name: sku
  }
  properties: {
    customSubDomainName: toLower(openaiAccName)
  }
}
