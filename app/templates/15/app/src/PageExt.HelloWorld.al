// https://dev.azure.com/businesscentralapps/HelloWorld

// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!

pageextension <%= startId %> CustomerListExt_<%= suffix %> extends "Customer List"
{
    trigger OnOpenPage();
    begin
        Message('App published: Hello world');
    end;
}