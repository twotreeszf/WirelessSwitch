//
//  ControlPointListener.cpp
//  UPnPSwitch
//
//  Created by zhang fan on 13-8-5.
//  Copyright (c) 2013年 twotrees. All rights reserved.
//

#include "UPnPDeviceManager.h"
#include "../ErrorCheck.h"

#import "../NotficationDef.h"
#import <Foundation/Foundation.h>

PLT_DeviceDataReference CUPnPDeviceManager::QueryDevice(const std::string &deviceId)
{
	PLT_DeviceDataReference destDevice;
	{
		NPT_AutoLock lock(m_validDevices);
			
		NPT_ContainerFind(m_validDevices, PLT_DeviceDataFinder(deviceId.c_str()), destDevice);
	}
	
	return destDevice;
}

NPT_Result CUPnPDeviceManager::OnDeviceAdded(PLT_DeviceDataReference& device)
{
	_addDeviceByType(device, DEVICE_TYPE, SERVICE_TYPE, m_validDevices);
	
	return NPT_SUCCESS;
}

NPT_Result CUPnPDeviceManager::OnDeviceRemoved(PLT_DeviceDataReference& device)
{
	_removeDeviceByType(device, DEVICE_TYPE, SERVICE_TYPE, m_validDevices);
	
	return NPT_SUCCESS;
}

NPT_Result CUPnPDeviceManager::OnActionResponse(NPT_Result res, PLT_ActionReference& action, void* userdata)
{
	{
		if (!action->GetActionDesc().GetName().Compare(ACTION_NAME_QUERY_STATE))
		{
			NPT_Result ret = NPT_SUCCESS;
			
			NPT_String deviceId = action->GetActionDesc().GetService()->GetDevice()->GetUUID();
			
			NPT_String deviceState;
			ret = action->GetArgumentValue(ACTION_ARG_STATE, deviceState);
			ERROR_CHECK_BOOL(NPT_SUCCESS == ret);
			
			// notify device founded
			NSDictionary* infoDic = [NSDictionary dictionaryWithObjectsAndKeys:
									 [NSString stringWithUTF8String:deviceId], PARAM_DEVICE_ID,
									 [NSString stringWithUTF8String:deviceState], PARAM_DEVICE_STATE,
									 nil];
			
			[[NSOperationQueue mainQueue] addOperationWithBlock:^
			 {
				 [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:NOTIFY_RETURN_DEVICE_STATE object:nil userInfo:infoDic]
															postingStyle:NSPostASAP];
			 }];

		}
	}
	
Exit0:
	return NPT_SUCCESS;
}

NPT_Result CUPnPDeviceManager::OnEventNotify(PLT_Service* service, NPT_List<PLT_StateVariable*>* vars)
{
	
	return NPT_SUCCESS;
}

void CUPnPDeviceManager::_addDeviceByType(PLT_DeviceDataReference &device, const char *deviceType, const char *serviceType, NPT_Lock<PLT_DeviceDataReferenceList> &list)
{
	@autoreleasepool
	{
        NPT_String curDeviceType = device->GetType();
        CHECK_BOOL(curDeviceType == deviceType);
		
        PLT_Service* service = NULL;
        NPT_Result ret = device->FindServiceByType(serviceType, service);
        CHECK_BOOL(NPT_SUCCESS == ret && service);
		
        NPT_String deviceId = device->GetUUID();
        CHECK_BOOL(!deviceId.IsEmpty());
		
        {
            NPT_AutoLock lock(list);
			
            PLT_DeviceDataReference data;
            NPT_ContainerFind(list, PLT_DeviceDataFinder(deviceId), data);
            CHECK_BOOL(data.IsNull());
			
            list.Add(device);
			
			// notify device founded
			NSDictionary* infoDic = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSString stringWithUTF8String:deviceId], PARAM_DEVICE_ID,
			[NSString stringWithUTF8String:device->GetFriendlyName()], PARAM_DEVICE_NAME,
			nil];

			[[NSOperationQueue mainQueue] addOperationWithBlock:^
			{
				[[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:NOTIFY_DEVICE_FOUNDED object:nil userInfo:infoDic]
														   postingStyle:NSPostASAP];
			}];
        }
    }
	
Exit0:
    return ;
}

void CUPnPDeviceManager::_removeDeviceByType(PLT_DeviceDataReference &device, const char *deviceType, const char *serviceType, NPT_Lock<PLT_DeviceDataReferenceList> &list)
{
	@autoreleasepool
	{
        NPT_String curDeviceType = device->GetType();
        CHECK_BOOL(curDeviceType == deviceType);
		
        PLT_Service* service = NULL;
        NPT_Result ret = device->FindServiceByType(serviceType, service);
        CHECK_BOOL(NPT_SUCCESS == ret && service);
		
        NPT_String deviceId = device->GetUUID();
        CHECK_BOOL(!deviceId.IsEmpty());
		
        {
            NPT_AutoLock lock(list);
			
            PLT_DeviceDataReference data;
            NPT_ContainerFind(list, PLT_DeviceDataFinder(deviceId), data);
            CHECK_BOOL(!data.IsNull());
			
            list.Remove(device);
			
			// notify device lost
			NSDictionary* infoDic = [NSDictionary dictionaryWithObjectsAndKeys:
									 [NSString stringWithUTF8String:deviceId], PARAM_DEVICE_ID,
									 nil];
			
			[[NSOperationQueue mainQueue] addOperationWithBlock:^
			 {
				 [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:NOTIFY_DEVICE_LOST object:nil userInfo:infoDic]
															postingStyle:NSPostASAP];
			 }];

        }
    }
Exit0:
    return;
}
