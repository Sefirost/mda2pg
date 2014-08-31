mda2pg
======

VS Multi-Device Hybrid Apps to PhoneGap Build

Instructions
------
1 - Copy mda2pg.ps1 and mda2pg.xml to yout project directory

2 - Edit your .jsproj file and add the following target before closing tag "```</Project>```"

```xml
  <Target Name="AfterBuild" DependsOnTargets="BuildRipple" Condition="'$(Configuration)'=='Release'">
    <Exec Command="Powershell -ExecutionPolicy RemoteSigned Unblock-File '$(ProjectDir)\mda2pg.ps1'; Powershell -File '$(ProjectDir)\MDA2PG.ps1' -OutDir '$(ProjectDir)\bld\Ripple\$(Platform)\$(Configuration)'" />
  </Target>

```

3 - Edit the mda2pg.xml file and complete the settings
```xml
<Settings>
  <Mail>
    <Send>true</Send>
    <Server>smtp.gmail.com</Server>
    <Port>587</Port>
    <Ssl>true</Ssl>
    <From>YourUser@gmail.com</From>
    <To>YourUser@gmail.com</To>
    <Subject>New PhoneGap Build</Subject>
    <Body><![CDATA[your-message-here]]></Body>
    <Username>YourUser</Username>
    <Encrypted>false</Encrypted>
    <Password>Password</Password>
  </Mail>
  <Git>
    <CopyToRepo>false</CopyToRepo>
    <Path>C:\Users\You\Source\Repos\MyRepo</Path>
  </Git>
  <PhoneGap>
    <ClientId></ClientId>
    <ClientSecret></ClientSecret>
    <AuthToken></AuthToken>
    <AppId></AppId>
  </PhoneGap>
</Settings>

```
