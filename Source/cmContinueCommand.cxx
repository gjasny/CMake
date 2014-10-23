/*============================================================================
  CMake - Cross Platform Makefile Generator
  Copyright 2000-2014 Kitware, Inc., Insight Software Consortium

  Distributed under the OSI-approved BSD License (the "License");
  see accompanying file Copyright.txt for details.

  This software is distributed WITHOUT ANY WARRANTY; without even the
  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the License for more information.
============================================================================*/
#include "cmContinueCommand.h"

// cmContinueCommand
bool cmContinueCommand::InitialPass(std::vector<std::string> const&,
                                  cmExecutionStatus &status)
{
  status.SetContinueInvoked(true);
  return true;
}

